From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] trace_events: fix napi's tracepoint
Date: Tue, 25 Aug 2009 09:58:16 +0200
Message-ID: <20090825075816.GB857@elte.hu>
References: <4A937EF5.4040505@cn.fujitsu.com> <4A93895F.4010708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:59356 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887AbZHYH60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 03:58:26 -0400
Content-Disposition: inline
In-Reply-To: <4A93895F.4010708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Xiao Guangrong <xiaoguangrong@cn.fujitsu.com> wrote:

> Currently, the napi's tracepoint works will is depend on
> "DECLARE_TRACE" definiens in include/trace/define_trace.h,
> like below:
> 
> #include <trace/events/skb.h>    // include define_trace.h
> #include <trace/events/napi.h>
> 
> there have error, if we remove "#include <trace/events/skb.h>"
> or include napi.h in the front of include skb.h, It should
> depend on the definiens in include/linux/tracepoint.h and we
> can remove the "DECLARE_TRACE" definiens in
> include/trace/define_trace.h, because "TRACE_EVENT" not use it
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
> ---
>  include/trace/define_trace.h |    4 ----
>  net/core/net-traces.c        |    4 +++-
>  2 files changed, 3 insertions(+), 5 deletions(-)

This will collide with tracing bits in the networking tree. The 
skb-tracing plugin there should be turned into proper TRACE_EVENT() 
tracepoints.

Neil was away for some time but i think soon we should see some 
movement here.

	Ingo
