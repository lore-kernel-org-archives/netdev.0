From: Andi Kleen <ak@suse.de>
Subject: Re: in-driver QoS
Date: Mon, 7 Jun 2004 16:00:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607140011.GC28639@wotan.suse.de>
References: <200406062128.47070.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
Content-Disposition: inline
In-Reply-To: <200406062128.47070.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Any ideas how to modify stack to support multiple Tx queues?

It already has that kind of in the form of arbitary qdiscs. The trick
will be only to do all queueing in the qdisc and keep the hardware
queue length as small as possible. I think today's drivers can
do that already by just plugging the queue most of the time,
unless they really want a packet.

Disadvantage will be more use of CPU time to refill driver
queues, but at the relatively slow WLAN speeds that shouldn't 
be a big issue.

BTW the standard qdisc pfifo_fast already has three queues,
selected by the old TOS.  That may even be good enough for you
already. Users can fine tune it by using firewall rules
that change the TOS for specific protocols etc.

-Andi
