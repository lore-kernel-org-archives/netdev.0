From: =?ISO-8859-1?Q?Roar_Bj=F8rgum_Rotvik?= <roarbr@tihlde.org>
Subject: Re: Where Linux 802.11x support needs work
Date: Wed, 26 Jan 2005 08:31:35 +0100
Message-ID: <41F74757.3090104@tihlde.org>
References: <20050126024039.GA25326@bougret.hpl.hp.com> <Pine.LNX.4.58.0501252224000.4275@devserv.devel.redhat.com> <200501252341.27041.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200501252341.27041.flamingice@sourmilk.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> On Tuesday 25 January 2005 11:03 pm, Dan Williams wrote:
> 
>>> One of the big item not mentionned by you is the in-kernel
>>>802.11 stack (native frames and management). If done right, I guess it
>>>would mostly be transparent to you...
>>
>>You know, I was thinking of it and I just forgot to put it on the list.
>>If you're including madwifi and ipw2x00, we have a grand total of what, 3
>>or 4 802.11 stacks in the kernel at the same time?  (madwifi,
>>orinoco/hermes, ipw2x00, linux-wlan-ng)
>>
> 
> Only orinoco/hermes is in the kernel, and that doesn't really have much of an 
> 802.11 stack, since most things are done in hardware. Madwifi has a fairly 
> complete 802.11 stack (ported from netbsd), and so does adm8211. Dunno about 
> ipw2x00.

Do any of these 80.11 stacks (or the upstream linux network stack) have 
a solution for WLAN cards with 802.11e (QoS extension) with more than 
one HW/firmware transmit queues?

As you may or may not know WLAN cards implementing 802.11e may have more 
than one HW/firmware transmit queue (I know of an 802.11a chip with 
802.11e extension that have 4 transmit queues in hardware/firmware with 
different priority).

As far as I know the linux network stack today only have one qdisc queue 
pr. device (struct netdev), so the driver may only stop/start 
(netif_stop_queue()/netif_wake_queue()) one queue at a time. This is a 
problem for drivers with more than one HW/firmware transmit queues, as 
you can not let a full low priority HW queue block the netdev queue.

Is there an existing solution for this problem, or is an 
multiqueue-pr-device solution being planned as part of introducing a 
common 802.11 stack in the kernel?

-- 
Roar B. Rotvik
