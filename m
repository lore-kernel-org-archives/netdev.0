From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: Wed, 9 Jun 2004 23:09:53 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFCBC67DF9.898B09C6-ON88256EAF.001BFC9E-88256EAF.001C4AB8@us.ibm.com>
References: <20040607115921.GB32569@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andrew Morton <akpm@osdl.org>, David Dillow <dave@thedillows.org>,
        Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040607115921.GB32569@k3.hellgate.ch>
To: Roger Luethi <rl@hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netdev-bounce@oss.sgi.com wrote on 06/07/2004 04:59:21 AM:

> One thing maybe worth mentioning: If you want to play with different
> addresses, remember that IP addresses are in decimal notation, ethernet
> in hex. So if you set

> target# ip maddr add 01:00:5e:00:00:25 dev eth0

> the test would be

> tester# ping -r -I eth0 -t 1 -c 2 224.0.0.37

This will add "01:00:5e:00:00:25" to the device multicast address filter,
which will mean the host will receive the packet. But because it doesn't
join the group at the IP level, it'll be dropped and the ping won't be
answered (it isn't for a local address).

If you want the machine to answer, you need to join the group, which
will conveniently add the hardware multicast address automatically. :-)

                                +-DLS
