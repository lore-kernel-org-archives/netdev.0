From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] ftrace: change the export format of
 trace_kfree_skb()
Date: Thu, 18 Jun 2009 08:51:12 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0906180847540.6890@gandalf.stny.rr.com>
References: <4A2DF91F.7030906@cn.fujitsu.com> <20090609182730.GA6057@nowhere> <4A2F0F1D.7010101@cn.fujitsu.com> <20090610072618.GA6016@nowhere> <4A39B3E4.6060004@cn.fujitsu.com> <20090618103538.GA8978@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:36617 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763499AbZFRMvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 08:51:17 -0400
In-Reply-To: <20090618103538.GA8978@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 18 Jun 2009, Neil Horman wrote:
> > 
> > diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
> > index 1e8fabb..2496060 100644
> > --- a/include/trace/events/skb.h
> > +++ b/include/trace/events/skb.h
> > @@ -7,6 +7,71 @@
> >  #undef TRACE_SYSTEM
> >  #define TRACE_SYSTEM skb
> >  
> > +#define protocol_name(protocol) { protocol, #protocol }
> > +#define show_protocol_name(val)					\
> > +	__print_symbolic(val,					\
> 
> Don't you need to include ftrace.h to pull in the __print_symbolic definition?
> Or is that always guaranteed to be included from tracepoint.h?

Its use is in one of the fields of TRACE_EVENT that are only used by 
define_trace.h. All other users will ignore it.

#define TRACE_EVENT(name, proto, args, struct, assign, print)	\
	DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))

Only name, proto, args is used. The define_trace.h will include 
trace/ftrace.h and that will use the struct, assign and print args.

So the answer is "no" ;-)

-- Steve

