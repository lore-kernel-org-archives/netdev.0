From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] trace_events: fix napi's tracepoint
Date: Wed, 26 Aug 2009 10:01:20 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0908260957470.23885@gandalf.stny.rr.com>
References: <4A937EF5.4040505@cn.fujitsu.com> <4A93895F.4010708@cn.fujitsu.com> <4A94C612.60200@cn.fujitsu.com> <4A94CACD.6020309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757485AbZHZOBZ@vger.kernel.org>
In-Reply-To: <4A94CACD.6020309@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 26 Aug 2009, Xiao Guangrong wrote:

> 
> 
> Xiao Guangrong wrote:
> > 
> > Xiao Guangrong wrote:
> >> Currently, the napi's tracepoint works will is depend on
> >> "DECLARE_TRACE" definiens in include/trace/define_trace.h,
> >> like below:
> >>
> >> #include <trace/events/skb.h>    // include define_trace.h
> >> #include <trace/events/napi.h>
> >>
> >> there have error, if we remove "#include <trace/events/skb.h>"
> >> or include napi.h in the front of include skb.h, It should
> >> depend on the definiens in include/linux/tracepoint.h and we
> >> can remove the "DECLARE_TRACE" definiens in
> >> include/trace/define_trace.h, because "TRACE_EVENT" not use it
> >>
> >> Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
> > 
> > Hi Steven,
> > 
> > I'm sorry, please pull this patch too, because 
> > "[PATCH 7/8] tracing/events: fix the include file dependencies" 
> > is based on this patch, else will occur building error.
> > 
> 
> Sorry again, I say the wrong words, it not has building error, just
> not complete fix the bug which I mention it in the changelog of
> "[PATCH 7/8] tracing/events: fix the include file dependencies", that
> is we can't include more TRACE_EVENT head file in .c file all the same,
> like below:
> 
> Both define TRACE_EVENT in trace_a.h and trace_b.h, if we include
> those in .c file, like this:
> 
> #define CREATE_TRACE_POINTS
> include <trace/events/trace_a.h>  // re-define DECLARE_TRACE
> 
> include <trace/events/trace_b.h>  // use the DECLARE_TRACE definition
> 				  // that re-define by trace_a.h

Hi Xiao,

I pushed out the "fix the include file dependencies" patch since that was 
a bug fix in its own right. I held off the NAPI patch because it looked 
like it needed rework and only depended on the include dependencies fix. 

Could you update this code to do as Neil and Ingo has mentioned.

Thanks,

-- Steve
