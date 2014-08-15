From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 17:33:55 -0700
Message-ID: <53ED5573.3030507@hp.com>
References: <53ECFDAB.5010701@intel.com> <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com> <53ED4354.9090904@intel.com> <1408060093.6804.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2352.austin.hp.com ([15.217.128.51]:47045 "EHLO
	g2t2352.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbaHOAd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 20:33:57 -0400
In-Reply-To: <1408060093.6804.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2014 04:48 PM, Eric Dumazet wrote:
> Here is the thing
>
> nh_pcpu_rth_output is a per cpu cache.
>
> But nh_rth_input is not, because we did not optimize the case where dst
> has to be refcounted, yet.
>
> Rationale is explained in d26b3a7c4b3b26319f18bb645de93eba8f4bdcd5
> ("ipv4: percpu nh_rth_output cache")
>
> If you guys really believe we should have a percpu dst, go for it, but
> again, if the softirq handler runs on a different cpu than the
> application thread, it wont work.
>
> And, given 72 core servers are now on the way, we'll consume more ram,
> for netperf users.

Heck, we've had >= 72 core servers for *years* - go back to the 
Itanium-based Superdome servers for example, and I suspect some of their 
Power-based contemporaries.  They just weren't plentiful.  After that, 
there were/are the 8-socket x86 boxes from various vendors, and now the 
BL920s.

I will not claim that netperf represents all apps.  Neither will I claim 
it represents most apps.  But I won't accept that it represents no apps :)

And if there is a reasonably clean way to introduce epoll/poll/select 
into netperf I'm willing to consider it.

happy benchmarking,

rick jones
