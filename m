From: Florian Westphal <fw@strlen.de>
Subject: Re: kernel BUG in ipmr_queue_xmit()
Date: Fri, 30 Oct 2015 01:15:10 +0100
Message-ID: <20151030001510.GG18062@breakpoint.cc>
References: <alpine.OSX.2.00.1510291646320.59200@animac.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ani@anirban.org, fruggeri@arista.com
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60968 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757072AbbJ3APO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 20:15:14 -0400
Content-Disposition: inline
In-Reply-To: <alpine.OSX.2.00.1510291646320.59200@animac.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ani Sinha <ani@arista.com> wrote:

[ trimmed CC list ]

> We are noticing the following kernel BUG in 3.18 kernel. The 
> code path that leads to the crash is the following :
> 
>  ip_mroute_setsockopt()
>   ->ipmr_mfc_add()
>       ->ipmr_cache_resolve()
>         ->ip_mr_forward()
>            -> ipmr_queue_xmit()
>              -> ipmr_forward_finish()
>                ->IP_INC_STATS_BH()
>                   -> SNMP_INC_STATS64_BH()
>                     -> SNMP_INC_STATS_BH()
>                           -> __this_cpu_inc()
>                               -> __this_cpu_add()
>                                   -> __this_cpu_preempt_check()
>                                      -> check_preemption_disabled()
> 
> I have verified that preempt_count() is 0 when the crash happens.
> Is anyone else seeing the same crash in the laetst upstream code? I dug 
> around a little bit and it does not look like there were any fixes that 
> went into post 3.18 kernel which could have disabled preemption in this 
> code path but I could be wrong. 
> 
> thoughts?

Send a patch to preempt_disable before ip_mr_forward call in the affected
setsockopt path?
