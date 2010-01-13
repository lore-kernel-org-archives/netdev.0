From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 13 Jan 2010 16:16:36 -0500
Message-ID: <4B4E3834.3000609@majjas.com>
References: <20100107185040.GB3208@del.dom.local> <4B466A26.5070506@majjas.com>
 <20100108074539.GA6205@ff.dom.local> <4B475FF9.7000702@majjas.com>
 <20100108212923.GA3078@del.dom.local> <4B47A81B.5040601@majjas.com>
 <4B4809EF.1070609@majjas.com> <20100109122830.GA4386@del.dom.local>
 <4B48CC2C.2090403@majjas.com> <4B4E2F89.2050606@majjas.com>
 <20100113210908.GA3065@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.srv.hcvlny.cv.net ([167.206.4.196]:34443 "EHLO
	mta1.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322Ab0AMVRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 16:17:34 -0500
In-reply-to: <20100113210908.GA3065@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/2010 4:09 PM, Jarek Poplawski wrote:
> On Wed, Jan 13, 2010 at 03:39:37PM -0500, Michael Breuer wrote:
>    
>> Just an FYI - 2.6.32.3 with alt 3 af_packet patch&  sky2
>> pskb_may_pull runs OK with DMAR (re)enabled and msi enabled.
>>      
> Hmm... What a pity! It was such a useful debugging tool for
> networking ;-) BTW, I'm not sure if "runs OK" means with or without
> those DHCP drops&  large packets you described.
>
> Thanks,
> Jarek P.
>    
As of now, no errors even when blasting traffic & forcing dhcp packets 
as before. I haven't tried putting mtu back to 9k yet. OK means that 
there are no obvious differences in behavior with or without DMAR all 
else being equal.

There were some updates made to stable that could have fixed this - I'd 
guess intel_iommu fixes helped.

If it helps, I'm still getting one error without DMAR enabled - at 
startup, there's a DMA sync oops - mismatch of 72 bytes coming from 
sky2. That oops was posted previously - with DMAR (re) enabled, there's 
no related oops.
