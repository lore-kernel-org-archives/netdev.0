From: jamal <hadi@cyberus.ca>
Subject: Re: ethernet QoS support?
Date: 09 Jul 2004 10:33:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089383622.1030.21.camel@jzny.localdomain>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
	 <200407091002.26410.vkondra@mail.ru>
	 <1089379137.1047.242.camel@jzny.localdomain>
	 <200407091641.35651.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200407091641.35651.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-09 at 09:41, Vladimir Kondratiev wrote:

> So far, I have hardware related parts working. I rely on skb->priority to 
> determine traffic class and select proper queue.

Who marks the skb->priority? Is that the default mark as per TOS?
I think the VLAN code marks it as well.

> All this worth nothing if one can't do separate queues. qdisc assignment for 
> driver is not in driver's hands, so it can't do any assumptions.
>  Generic 
> in-kernel support needed here. Stack should allow driver to request 
> additional Tx queues, providing some classifiers for each one. I tried to 
> imagine how to work it around, but there is no good solution without those 
> several queues.

I dont think we should put intelligence at the driver level.
We can have drivers configured via parameter to look at the priority
field. Only then do they look at it; else use only single ring.
When multi-ring is on, you intepret the priority. 
priority field is set above driver based on which priority queue the
packet was grabbed from (before sending to driver).

> This mean, I will be able to deliver QoS support when network stack will make 
> it possible.

So what do you do now?

cheers,
jamal
