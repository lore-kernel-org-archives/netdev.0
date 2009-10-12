From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: NOHZ: local_softirq_pending 08
Date: Mon, 12 Oct 2009 10:28:56 +0200
Message-ID: <4AD2E8C8.4060205@imap.cc>
References: <20091011095217.GA2200@darkstar>	 <1255255735.4095.53.camel@johannes.local>	 <4AD1BF06.3050103@phoenixsoftware.de> <1255261251.4095.143.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Young <hidave.darkstar@gmail.com>,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754793AbZJLI3j@vger.kernel.org>
In-Reply-To: <1255261251.4095.143.camel@johannes.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

[CCing PPP people]

Am 11.10.2009 13:40 schrieb Johannes Berg:
> On Sun, 2009-10-11 at 13:18 +0200, Tilman Schmidt wrote:
>=20
>> Can you explain a bit more what that message is about?
>> I am encountering it in a completely different context
>> (PPP over ISDN) [...]
>=20
> Basically, calling netif_rx() with softirqs enabled.

AFAICS that would have to be the netif_rx() call in
ppp_receive_nonmp_frame() [drivers/net/ppp_generic.c#L1791],
called (via others) from the tasklet work function
ppp_sync_process() [drivers/net/ppp_synctty.c#L545].
Should that be changed to the
"if (in_interrupt()) netif_rx(skb) else netif_rx_ni(skb)"
stanza from the linux.kernel.wireless.general thread then?

Thanks,
Tilman

- --
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFK0ujIQ3+did9BuFsRAtGBAJ9rj2pyQZ75ZKTipLhpICqA3ZvTdQCdHQs/
RmdeOT3TuPZykXJxcHLJCzU=3D
=3D87DI
-----END PGP SIGNATURE-----
