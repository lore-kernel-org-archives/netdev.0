From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 01 Jul 2006 09:35:01 -0400
Message-ID: <1151760901.5093.141.camel@jzny2>
References: <44A5606B.5080003@trash.net> <1151697554.5270.241.camel@jzny2>
	 <20060630203034.GN14627@postel.suug.ch>
	 <20060630.133348.68039806.davem@davemloft.net>
	 <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch>
	 <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch>
	 <1151722785.5093.51.camel@jzny2>  <20060701112833.GS14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:53923 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751230AbWGANfI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jul 2006 09:35:08 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fwfcs-0003Qt-Az
	for netdev@vger.kernel.org; Sat, 01 Jul 2006 09:35:10 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060701112833.GS14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-01-07 at 13:28 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-30 22:59

> Please enlighten me, I may be making a wrong assumption again.
> 
> 1) tc_verd is reset to 0 after dq in ri_tasklet()
> 2) TC_AT is set to AT_EGRESS in dev_queue_xmit()
> 3) TC_FROM being derived from TC_AT in tcf_mirred() when redirecting
> 4) TC_FROM has the value AT_EGRESS when entering ifb_xmit()
> 

Let me answer the next bit and it may clear this.

> > different instances of the same device do not deadlock. If however, you
> > have a series of devices in which A->B->C->D->A then you will have a
> > possible deadlock. In the case of the ifb i dissallowed it because it
> > was obvious from the testing. 
> 
> Correct me if I'm wrong. The skb is queued between each device. When
> moving skbs from rq to tq the tx lock is acquired, if not available
> the packet is requeued for later. Due to the queueing the tx lock
> of the previous device is released. Where exactly is the deadlock?

using what i said as looping in the case of A->B->C->D->A for the case
of egress since that is what you are alluding to;
note that ifb0 will be entered twice: First for example the tasklet in
ifb0 will emit the packet, and then it will go all the way back to xmit
on ifb0. This is where the issue is. Does that clear it?

cheers,
jamal


