From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 15 Nov 2004 07:52:50 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0411150735070.10262@hibernia.jakma.org>
References: <OF88EC0E9F.DE8FC278-ONC1256F4A.0038D5C0-C1256F4A.00398E11@de.ibm.com>
 <4196B4E9.40502@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>, linux-kernel@vger.kernel.org,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4196B4E9.40502@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 13 Nov 2004, Jeff Garzik wrote:

> Queues are DESIGNED to fill up under various conditions.

What happens when they are full? Blocking isnt good, at least not 
from GNU Zebra / Quagga's POV.

> Would not the zebra routing software have the same problems with 
> cable pull under an e1000 or tg3 gigabit NIC?

If they block further writes, yes.

> The most popular drivers -- e1000, tg3, etc. -- do not do this, for 
> very good reasons.

The problem is that GNU Zebra / Quagga uses a single raw socket for 
certain protocols, eg OSPF. Blocking the socket because one NIC has a 
cable pulled is undesireable, and there's no point queueing the 
packets, by the time the link comes back, if ever, its highly 
unlikely there is any use in sending the packets (sending OSPF 
hello's from X minutes ago on a link that just came back is useless).

The kernel really shouldnt get too much in the way of an application 
that already is fully aware of reliability issues[1] - at least that 
is the application's expectation in this case.

We could change it to use a socket/interface on Linux, but it seems a 
bit unnecessary to me, at least for raw socket/included-header 
sockets.

> 	Jeff

1. an application must be if its uses raw sockets surely? Even for 
non-raw/header-included sockets, eg BGP tcp sockets, a user like GNU 
Zebra / Quagga would much prefer packets to be dropped.

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
My interest is in the future because I am going to spend the rest of my
life there.
