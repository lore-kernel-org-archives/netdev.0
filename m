From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Tue, 05 Apr 2005 21:48:45 +0200
Message-ID: <4252EB9D.9070305@trash.net>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050329152110.38d50653@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Netem has a private queue for delayed packets, and currently, packets
> in this queue are not accounted for in the qdisc qlen statistics.
> This is a problem if netem is used inside another qdisc doing rate
> control that peeks at the qlen.
> 
> This patch changes the statistics to include the packets held but
> not ready to send.

There is one troublesome spot left, netem_watchdog() decreases q.qlen
when the packet couldn't be enqueued. I don't think it is possible
to make netem useable as leaf-qdisc, it will always have to touch
q.qlen from timer context and classful qdiscs can't deal with this
since they all maintain their own q.qlen counters and expect changes
only in the +-1 range in enqueue/dequeue/requeue/drop. Best thing IMO
would be to refuse to work as anything but root qdisc.

Regards
Patrick
