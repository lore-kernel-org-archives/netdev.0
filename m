From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] net: Allow no-cache copy from user on transmit
Date: Wed, 23 Mar 2011 11:51:23 -0700
Message-ID: <1300906283.25347.1467.camel@tardy>
References: <alpine.DEB.2.00.1103231003120.16608@pokey.mtv.corp.google.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:47809 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755164Ab1CWSvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 14:51:25 -0400
In-Reply-To: <alpine.DEB.2.00.1103231003120.16608@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-23 at 10:10 -0700, Tom Herbert wrote:
> This patch uses __copy_from_user_nocache (from skb_copy_to_page)
> on transmit to bypass data cache for a performance improvement.
> This functionality is configurable per device using ethtool, the
> device must also be doing TX csum offload to enable.  It seems
> reasonable to set this when the netdevice does not copy or
> otherwise touch the data.
> 
> This patch was tested using 200 instances of netperf TCP_RR with
> 1400 byte request and one byte reply.  Platform is 16 core AMD x86.
> 
> No-cache copy disabled:
>    672703 tps, 97.13% utilization
>    50/90/99% latency:244.31 484.205 1028.41
> 
> No-cache copy enabled:
>    702113 tps, 96.16% utilization,
>    50/90/99% latency 238.56 467.56 956.955
> 
> Using 14000 byte request and response sizes demonstrate the
> effects more dramatically:
> 
> No-cache copy disabled:
>    79571 tps, 34.34 %utlization
>    50/90/95% latency 1584.46 2319.59 5001.76
> 
> No-cache copy enabled:
>    83856 tps, 34.81% utilization
>    50/90/95% latency 2508.42 2622.62 2735.88
> 
> Note especially the effect on tail latency (95th percentile).
> 
> This seems to provide a nice performance improvement and is
> consistent in the tests I ran.  Presumably, this would provide
> the greatest benfits in the presence of an application workload
> stressing the cache and a lot of transmit data happening.  I don't
> yet see a downside to using this.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Having raised the question about tying it to CKO and seeing it addressed
to my satisfaction I'll go ahead and:

Acked-by: Rick Jones <rick.jones2@hp.com>

rick jones

