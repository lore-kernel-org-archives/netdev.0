From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Query on Linux Kernel Network - Transmission Path
Date: Tue, 27 Jul 2010 15:50:41 -0700
Message-ID: <20100727155041.7f841e24@nehalam>
References: <20100727221555.GC17237@kumar.broadband.vsnl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kumar Sanghvi <divinekumar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37007 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725Ab0G0Wup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 18:50:45 -0400
In-Reply-To: <20100727221555.GC17237@kumar.broadband.vsnl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jul 2010 03:45:55 +0530
Kumar Sanghvi <divinekumar@gmail.com> wrote:

> Hi All,
> 
> I have a query on the Transmission Path for the Linux Kernel Network
> stack.
> I understand that Qdisc/Traffic control can be used to prioritize
> traffic on a per net_device basis.
> 
> However, I would like to know how to prioritize traffic between the
> net_device(s) ?
> 
> Assume the below scenario:
> -A Linux server has two net_device.
> -One net_device -eth0, deals with IPv4 traffic over Ethernet
>  This eth0 net_device is heavily loaded and there is a continuous
> network activity going on.
> 
> -2nd net_device -ph0, deals with Phonet traffic.
>  It occassionally transmits Voice traffic. It is required that traffic
> over net_device ph0 should not suffer any delay.
> 
> Now as I understand, for the transmission path, the function
> "__netif_schedule" will queue a net_device on the output_queue of
> sofnet_data.
> Also, the net_tx_action will pick up the net_device from output_queue
> of softnet_data on last-in--first-out basis.
> 
> So, since eth0 has always IPv4 traffic to be sent, it will get queued
> up continously in the output_queue of softnet_data. In this scenario,
> what would happen to the ph0 device carrying the Phonet traffic? Will
> the ph0 device get a chance to queue up on the output_queue of
> softnet_data in the middle of continously coming IPv4 traffic from
> eth0?
> Or will the ph0 get starved in this case? Or the ph0 will suffer a
> delay in getting scheduled for transmission?
> 
> In short, is there any way to prioritize the transmission among the
> net_device eth0 and ph0 i.e. is it possible to queue up ph0 carrying
> Phonet traffic on output_queue of softnet_data first in comparison to
> eth0 carrying IPv4 data, so that ph0 traffic does not suffer any delay?
> 
> Pardon me if I have misunderstood anything or if my knowledge is
> outdated in this regards.
> I would really appreciate some pointers related to this priority among
> net_device(s) for transmission.
> 
> Thanks & Regards,
> Kumar.

No, there is no way to coordinate between devices.
The second device (if it is on the same physical network), is unlikely
to solve your problem.

The more common way is to use a single device and prioritize traffic
using a qdisc like HTB or HFSC which can guarantee bandwidth for
a class of traffic.



-- 
