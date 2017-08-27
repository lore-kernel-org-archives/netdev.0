From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Sun, 27 Aug 2017 09:56:17 -0700
Message-ID: <0D360298-6B3C-42BA-8E56-9F56E9B29BE4@gmail.com>
References: <20170816075524.GA18532@amd> <20170816140451.GA13006@lunn.ch> <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com> <20170827123658.GA727@amd>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Tristram.Ha@micrel.com,
        andrew@lunn.ch, pavel@denx.de
To: Pavel Machek <pavel@denx.de>, Woojung.Huh@microchip.com,
        nathan.leigh.conrad@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170827123658.GA727@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On August 27, 2017 5:36:58 AM PDT, Pavel Machek <pavel@denx=2Ede> wrote:
>Hi!
>
>So I fought with the driver a bit more, and now I have something that
>kind-of-works=2E
>
>"great great hack" belows worries me=2E
>
>Yeah, disabled code needs to be removed before merge=2E
>
>No, tag_ksz part probably is not acceptable=2E Do you see solution
>better than just copying it into tag_ksz1 file?

You could have all Micrel tag implementations live under net/dsa/tag_ksz=
=2Ec and have e=2Eg: DSA_TAG_PROTO_KSZ for the current (newer) switches and=
 DSA_TAG_PROTO_KSZ_LEGACY (or any other name) for the older switches and yo=
u would provide two sets of function pointers depending on which protocol i=
s requested by the switch=2E

Considering the minor difference needed in tagging here, it might be accep=
table to actually keep the current functions and just have the xmit() call =
check what get_tag_protocol returns and use word 1 or 0 based on that=2E Ev=
en though that's a fast path it shouldn't hurt performance too much=2E If i=
t does, we can always copy the tagging protocol into dsa_slave_priv so you =
have a fast access to it=2E

>
>Any more comments, etc?

The MII emulation bits are interesting, was it not sufficient if you imple=
mented phy_read and phy_write operations that perform the necessary interna=
l PHY accesses or maybe you don't get access to standard MII registers? b53=
 does such a thing and we merely just need to do a simple shift to access t=
he MII register number, thus avoiding the translation=2E

>
>Help would be welcome=2E

I concur with Andrew, try to get a patch series, even an RFC one together =
so we can review things individually=2E=20

How functional is your driver so far? I'd say the basic stuff to get worki=
ng: counters (debugging), link management (auto-negotiation, forced, etc=2E=
) and basic bridging: all ports separate by default and working port to por=
t switching when brought together in a bridge=2E VLAN, FDB, MDB, other etht=
ool goodies can be added later on=2E

--=20
Florian
