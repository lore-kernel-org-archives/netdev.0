From: Daniele Orlandi <daniele@orlandi.com>
Subject: Clarifications on queues
Date: Fri, 17 Dec 2004 05:29:28 +0100
Message-ID: <200412170529.28898.daniele@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello,

I'm trying to understand how netdev works wrt the queueing.
Here is what I deducted, please correct me if there is something or everything 
wrong :)

There is a transmit queue associated to the device which is managed by the 
Qdisc discipline manager. Once a skb has been enqueued into the Qdisk queue 
(by dev_queue_xmit) it is destined to the device via hard_start_xmit and the 
sender shouldn't mess with it.

In the upper layer there is sk_write_queue which is managed by the protocol 
implementation and enqueing/dequeuing is made thru skb_queue_*
If the protocol needs to cope with retransmissions, I can use this queue.

Now, some question :)

The (low-speed) device I'm working with has a FIFO managed by the hardware 
into which I write frames to be transmitted. Is it ok if I put frames in the 
FIFO without restrictions? I mean, from a performances viewpoint, is it good 
if the FIFO fills eventually up or is it better to keep it empty or almost 
empty and let the device queueing be handled by netdev?

Thank you,
Bye!

-- 
  Daniele Orlandi
