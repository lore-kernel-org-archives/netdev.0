From: Michael Renzmann <mrenzmann@web.de>
Subject: Minor bug in tun.c
Date: Fri, 15 Oct 2004 13:14:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416FB0F9.6040203@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all.

I'm currently trying to learn a bit more about driver programming, 
therefore I'm working a little with tun.c (using the version that comes 
with 2.6.7). I have some experience with C programming in general, but 
I'm a newbie when it comes to kernel stuff.

Have a look at the following code (taken from the function tun_net_xmit()):

=== cut ===
	/* Queue packet */
	if (!(tun->flags & TUN_ONE_QUEUE)) {
		/* Normal queueing mode.
		 * Packet scheduler handles dropping. */
		if (skb_queue_len(&tun->readq) >= TUN_READQ_SIZE)
			netif_stop_queue(dev);
	} else {
		/* Single queue mode.
		 * Driver handles dropping itself. */
		if (skb_queue_len(&tun->readq) >= dev->tx_queue_len)
			goto drop;
	}
	skb_queue_tail(&tun->readq, skb);
=== cut ===

Look at the code that is executed when TUN_ONE_QUEUE isn't set in 
tun->flags. If the length of the queue has reached its maximum value 
(given as TUN_READQ_SIZE), the current packet still is appended to the 
queue, thereby exceeding the maximum length by 1.

In my eyes the simplest way to correct that would be to change

		if (skb_queue_len(&tun->readq) >= TUN_READQ_SIZE)

to read

		if (skb_queue_len(&tun->readq) >= TUN_READQ_SIZE - 1)

Please correct me if I'm wrong.

Bye, Mike
