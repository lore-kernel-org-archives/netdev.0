From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [RFC] IPSEC failover and replay detection sequence numbers
Date: Fri, 29 Oct 2004 15:24:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099056277.2888.71.camel@nienna.balabit>
References: <1099045435.2888.47.camel@nienna.balabit>
	 <1099054721.1027.118.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, ipsec-tools-devel@lists.sourceforge.net,
        vpn-failover@lists.balabit.hu
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099054721.1027.118.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


  Hi,

2004-10-29, p keltez=E9ssel 14:58-kor jamal ezt =EDrta:
> To take a rough estimate of 5K users, how often do you think
> these replay messages will be generated?
>=20
> Is there a (clever) way to avoid transporting them and still achieve
> an accurate failover?

  There is, provided that you do not want replay detection to work after
a failover. The more often you would send sequence number updates the
smaller the possible replay window will be. If you sacrifice scalability
you get more accurate replay detection.

  To play with numbers: say that you have 5K users, so let's suppose
there are at most 20K IPSEC SAs. If you decide to send an update per
second, that would mean 20K updates/second. If each update message is 20
bytes long, that means that on Ethernet you can transmit all of them in
about 280 packets. That's not too much. (I suppose the 20K pfkey
messages would be much more of a problem, though...)

--=20
 Regards,
   Krisztian KOVACS
