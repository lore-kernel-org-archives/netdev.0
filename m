From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] skb: Augment skb_copy_datagram_iovec TRACE_EVENT to dump
 more info
Date: Mon, 31 Aug 2009 15:05:44 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0908311503170.24907@gandalf.stny.rr.com>
References: <20090828203314.GA30417@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908281643190.25717@gandalf.stny.rr.com> <20090828231709.GA14063@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, mingo@elte.hu
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:57387 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbZHaTFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 15:05:44 -0400
In-Reply-To: <20090828231709.GA14063@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2009, Neil Horman wrote:
> > >  
> > >  /*
> > >   * Tracepoint for free an sk_buff:
> > > @@ -42,16 +43,35 @@ TRACE_EVENT(skb_copy_datagram_iovec,
> > >  	TP_ARGS(skb, len),
> > >  
> > >  	TP_STRUCT__entry(
> > > -		__field(	const void *,		skbaddr		)
> > > +		__field(	const struct sk_buff *,	skb		)
> > >  		__field(	int,			len		)
> > > +		__field(	int,			anid		)
> > > +		__field(	int,			cnid		)
> > > +		__field(	int,			rx_queue	)
> > > +		__dynamic_array(char,		name,	IFNAMSIZ	)
> > 
> > For string fields we have a __string macro:
> > 
> > 		__string(	char,			name		)
> > 
> Yeah, I was going to use that, but I ran into an issue, in that the __string
> macro expects, as its second of two arguments, a pointer to a string with witch
> to determine the dynamic arrays size.  The problem is that, if I'm to provide
> that, I need to point it to skb->dev->name, and there is no guarantee that
> skb->dev isn't NULL, at which point I think the use of string breaks down.  Note
> below that I obtain the dev pointer by other means and check its validity prior
> to assigning it.  If theres a better way to do this, please let me know.

Ah, OK I see the issue. The problem is the code that figures out the 
offset. It will always be calculated, and that would cause the skb->dev be 
evaluated and if NULL will cause an OOPS.

Yeah, keep the dynamic_array here then.

-- Steve

