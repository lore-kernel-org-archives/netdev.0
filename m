From: Joshua Stewart <joshua.stewart@comcast.net>
Subject: Following a packet from NIC to user space (and the reverse)
Date: Mon, 30 Dec 2002 22:37:32 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1041305853.12103.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I was given this email address by Alan Cox.  So, if this is a mistake
please let me know.

------------------------------------------------

I'm trying to get a really good grasp on what happens to packets from
when they arrive until they are pushed to user-space applications.  For
now I'm just assuming I am receiving a TCP packet.

I've read almost all the online docs I can find, but most don't get down
and dirty enough for what I'm trying to figure out.  For example,
http://www.gnumonks.org/ftp/pub/doc/packet-journey-2.4.html.  I also
have troubles with running into docs referring to the 2.0 or 2.2 kernels
and interrupt bottom halves, which it seems are not in the 2.4 network
code (softirqs instead).

I'd like to create a list of the functions (in order) that are called
from the time of sk_buff creation/allocation until the buffer is free'd
(kfree_skb).  I'd really like to track an sk_buff throughout it's
'lifespan' in the linux kernel.  So far I think I understand the
following, which isn't much...

Linux network drivers all register themselves with the kernel through a
register_netdev() call.  Lots of structures are allocated and
initialized.  It seems that most sk_buffs come into existence during an
interrupt routine in a NIC card driver (i.e.
/usr/src/linux/drivers/net/pci-skeleton.c, netdrv_rx_interrupt()), which
does the following...

netif_rx(skb) is called, which performs the following...

__skb_queue_tail(&queue->input_pkt_queue,skb); dev.c, line 1255

which puts the sk_buff into the incoming packet queue of one of the
processors, which is really a member of the softnet_data[] array.

>From this point on, I have no idea what happens to the packet.  I know
it has something to do with 2.4's new softirqs, but I don't really have
a good grasp on that yet.

Please help me fill in where my knowledge is lacking.  Also, PLEASE
correct any mistakes you see in my understanding so far.

Thanks,
        Joshua Stewart

joshua.stewart@comcast.net
