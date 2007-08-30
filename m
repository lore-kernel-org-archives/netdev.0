From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Thu, 30 Aug 2007 10:10:28 -0700
Message-ID: <46D6FA04.5050808@hp.com>
References: <OFD89921DD.675E7B9A-ON65257347.001C5D22-65257347.001D84A0@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ian.mcdonald@jandi.co.nz,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:42007 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756989AbXH3RL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 13:11:27 -0400
In-Reply-To: <OFD89921DD.675E7B9A-ON65257347.001C5D22-65257347.001D84A0@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 wrote:
> Hi Rick,
> 
> 
>>>From: Rick Jones <rick.jones2@hp.com>
>>>
>>>>The trace I've been sent shows clean RTTs ranging from ~200
> 
> milliseconds
> 
>>>>to ~7000 milliseconds.
>>>
>>>
>>>Thanks for the info.
>>>
>>>It's pretty easy to generate examples where we might have some sockets
>>>talking over interfaces on such a network and others which are not.
>>>Therefore, if we do this, a per-route metric is probably the best bet.
>>
>>FWIW, the places where I've seen this come-up thusfar are where we have
>>a sort of "gateway" or front-end system which is connected on one side
>>to the cellphone network with the bad delays, and on the other side is
>>connected to an internal network where actual losses leading to RTO's
>>are epsilon.  Certainly something which could make a per-route decision
>>would work there and probably quite well, though a simple sysctl does
>>seem to be sufficient and would touch fewer places.
>>
>>Do you think it is still worthwhile for me to rework the initial patch
>>to use CTL_UNNUMBERED?
> 
> 
> You could add following cleanup:
> 
> static int proc_tcp_rto_min(ctl_table *ctl, int write, struct file *filp,
>                                         void __user *buffer, size_t *lenp,
> loff_t *ppos)
> {
>       int *valp = ctl->data;
>       int oldval = *valp;
>       int ret;
> 
>       ret = proc_dointvec_ms_jiffies(ctl, write, filp, buffer, lenp, ppos);
>       if (ret)
>             return ret;
> 
>       /* some bounds checking would be in order */
>       if (write && *valp != oldval) {
>             if (*valp < (int)TCP_RTO_MIN || *valp > (int)TCP_RTO_MAX) {
>                   *valp = oldval;
>                   ret = -EINVAL;
>              }
>       }
>       return ret;
> }

Sure.

> Also, isn't it enough to use u32 for valp/oldval and remove the "(int)"
> typecasts?

I suppose, that was some mimicing of code I'd seen elsewhere but I'll 
give it a shot.

rick
