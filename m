From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC PATCH 02/13] extended semantic of sk_buff::tstamp: lowest
	bit	marks hardware time stamps
Date: Wed, 12 Nov 2008 09:09:04 +0100
Message-ID: <1226477344.31699.44.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
	 <1226415407.31699.1.camel@ecld0pohly>  <491A88AB.8070006@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30961 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144AbYKLIJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 03:09:09 -0500
In-Reply-To: <491A88AB.8070006@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 07:41 +0000, Eric Dumazet wrote:
> Please use ktime_t instead of "union ktime"

Are you sure? 

include/linux/ktime.h says
        typedef union ktime ktime_t;            /* Kill this */
and the CodingStyle also seems to be against it.

I thought it would be good to avoid using the typedef in new code, but
if consistency with the existing code is preferred, then I'll change it.

> > +
> > +	/*
> > +	 * make sure that lowest bit is never set: it marks hardware
> > +	 * time stamps
> > +	 */
> > +#if BITS_PER_LONG != 64 && !defined(CONFIG_KTIME_SCALAR)
> > +	skb->tstamp.tv.sec = skb->tstamp.tv.sec / 2 * 2;
> 
> .tv.sec ? are you sure you dont want .tv.nsec ?

Eek! Right. I'm pretty sure I compiled this in 32 bit mode, but I
haven't actually tried the result.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

