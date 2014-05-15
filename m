From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: interrupt moving and NAPI scheduling
Date: Thu, 15 May 2014 10:33:32 -0700
Message-ID: <1400175212.7973.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395756505-21573-1-git-send-email-david.vrabel@citrix.com>
	 <533195B6.5090305@citrix.com> <5374EAB4.2000701@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Vrabel <david.vrabel@citrix.com>,
	xen-devel@lists.xenproject.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:49045 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbaEORdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 13:33:35 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so1340244pab.6
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 10:33:34 -0700 (PDT)
In-Reply-To: <5374EAB4.2000701@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-15 at 17:26 +0100, Zoltan Kiss wrote:
> Hi,
> 
> Let me bump this question: how does the kernel make sure that if an 
> interrupt is moved away from CPU X to Y (e.g. by irqbalance), the NAPI 
> instance already scheduled on CPU Y won't race with the interrupt? I 
> mean the following scenario:
> 
> 1. instance calls napi_complete on CPU X
> 2. that removes the instance from the list
> 3. interrupt happens on CPU Y
> 4. "!test_and_set_bit(NAPI_STATE_SCHED, &n->state)" fails, as the bit is 
> still set
> 5. instance not added to the list therefore
> 6. napi_complete on CPU X clear the bit
> 
> My assumption is that when the interrupt moved, the kernel makes sure 
> the NAPI instance won't get scheduled on the old CPU, but I'm not sure 
> about it

Interrupts are supposed to be disabled at the time we call
napi_complete().

Some drivers are buggy.
