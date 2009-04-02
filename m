From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 15:43:52 +0300
Message-ID: <49D4B308.2030007@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <20090402091639.GA30126@gondor.apana.org.au> <49D484F5.2000400@redhat.com> <20090402092936.GA30333@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <49D4A89E.5090407@redhat.com> <49D4AFF7.1050603@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	Mark McLoughlin <markmc@redhat.com>
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48492 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755972AbZDBMoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 08:44:10 -0400
In-Reply-To: <49D4AFF7.1050603@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins wrote:

  

>> It's more of a "schedule and forget" which I think brings you the
>> win.  The host disables notifications and schedules the actual tx work
>> (rx from the host's perspective).  So now the guest and host continue
>> producing and consuming packets in parallel.  So long as the guest is
>> faster (due to the host being throttled?), notifications continue to
>> be disabled.
>>     
> Yep, when the "producer::consumer" ratio is > 1, we mitigate signaling. 
> When its < 1, we signal roughly once per packet.
>
>   
>> If you changed your rx_isr() to process the packets immediately
>> instead of scheduling, I think throughput would drop dramatically.
>>     
> Right, that is the point. :) This is that "soft asic" thing I was
> talking about yesterday.
>   

But all that has nothing to do with where the code lives, in the kernel 
or userspace.

-- 
error compiling committee.c: too many arguments to function

