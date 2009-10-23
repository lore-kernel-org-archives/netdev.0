From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: NOHZ: local_softirq_pending 08
Date: Fri, 23 Oct 2009 16:27:09 +0200
Message-ID: <4AE1BD3D.3020007@imap.cc>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local>	 <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>	 <4AE0ECCE.2020407@imap.cc> <1256304869.12174.20.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	i4ldeveloper <i4ldeveloper@listserv.isdn4linux.de>,
	Karsten Keil <isdn@linux-pingi.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1256304869.12174.20.camel@johannes.local>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Johannes Berg schrieb:
> On Fri, 2009-10-23 at 01:37 +0200, Tilman Schmidt wrote:
>=20
>> --- a/drivers/isdn/i4l/isdn_ppp.c
>> +++ b/drivers/isdn/i4l/isdn_ppp.c
>> @@ -1174,7 +1174,10 @@ isdn_ppp_push_higher(isdn_net_dev * net_dev, =
isdn_net_local * lp, struct sk_buff
>>  #endif /* CONFIG_IPPP_FILTER */
>>  	skb->dev =3D dev;
>>  	skb_reset_mac_header(skb);
>> -	netif_rx(skb);
>> +	if (in_interrupt())
>> +		netif_rx(skb);
>> +	else
>> +		netif_rx_ni(skb);
>=20
> So you've verified that the entire i4l stack can cope with being call=
ed
> twice on the same CPU, from different contexts?

What makes you think so?
Better yet, what do you propose?

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

iD8DBQFK4b09Q3+did9BuFsRAqBvAKCbRI0iXQEyK3ztxkGHcqpbcceqbACgkagX
JF7nYd152ihp2uemIs/cB54=3D
=3DYOin
-----END PGP SIGNATURE-----
