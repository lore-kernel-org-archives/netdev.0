From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/2] e1000: remove risky prefetch on next_skb->data
Date: Mon, 05 Jun 2006 17:16:27 -0700
Message-ID: <4484C95B.6010009@hp.com>
References: <20060605230917.12584.55755.stgit@gitlost.site>	<20060605231127.12584.14321.stgit@gitlost.site>	<4484BC62.3090707@hp.com> <Pine.WNT.4.63.0606051707520.1168@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:57561 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1751178AbWFFAQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 20:16:30 -0400
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.WNT.4.63.0606051707520.1168@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandeburg, Jesse wrote:
> On Mon, 5 Jun 2006, Rick Jones wrote:
>>Kok, Auke wrote:
>>
>>>It was brought to our attention that the prefetches break e1000 traffic
>>>on xscale/arm architectures.  Remove them for now.  We'll let them
>>>stay in mm for a while, or find a better solution to enable.
>>
>>Out of curiousity, what breaks?
> 
> 
> Hi Rick, according to our reporter, receives break.  The prefetch (not 
> always, but sometimes) lets the processor get junk from the prefetched 
> area.  Apparently this version of arm doesn't quite do as strict 
> enforcement of bus snoops as x86, ia64, (and even pSeries!) does.

Bear with me, I'm a software guy :)  I interpret that to mean that the 
processor is basically broken?  If so, wouldn't it be the case that 
prefetch() needs to become a noop on that processor?

> This manifested with a large drop in receive peformance using TCP, 
> probably because it was retransmitting frequently.

I forget - what were the gains on the other CPUs?

rick

> 
> Jesse

