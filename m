From: David Decotigny <decot@google.com>
Subject: Re: [PATCHv4 2/7] ethtool: Call ethtool's get/set_settings callbacks
 with cleaned data
Date: Thu, 28 Apr 2011 08:16:34 -0700
Message-ID: <BANLkTiku9A3V0kbj+tcO8Sp4o_JZ=d2jzg@mail.gmail.com>
References: <1303965163-8198-1-git-send-email-decot@google.com>
 <1303965163-8198-3-git-send-email-decot@google.com> <20110428073417.GA2220@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	mirq-linux@rere.qmqm.pl,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110428073417.GA2220@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Stanislaw, as Ben mentions, it's calling phy_ethtool_sset() which is
certainly meant to be an ETHTOOL_SSET op (from its name and comments)
even though its current implementation doesn't actually care for the
value of the cmd field.

Regards,

--
David Decotigny



On Thu, Apr 28, 2011 at 12:34 AM, Stanislaw Gruszka <sgruszka@redhat.co=
m> wrote:
> On Wed, Apr 27, 2011 at 09:32:38PM -0700, David Decotigny wrote:
>> --- a/drivers/net/stmmac/stmmac_ethtool.c
>> +++ b/drivers/net/stmmac/stmmac_ethtool.c
>> @@ -237,13 +237,12 @@ stmmac_set_pauseparam(struct net_device *netde=
v,
>>
>> =A0 =A0 =A0 if (phy->autoneg) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_running(netdev)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_cmd cmd;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_cmd cmd =3D=
 { .cmd =3D ETHTOOL_SSET };
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* auto-negotiation auto=
matically restarted */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmd.cmd =3D ETHTOOL_NWAY_R=
ST;
>
> Why did you change ETHTOOL_NWAY_RST to ETHTOOL_SSET ?
>
>
