From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] [PKT_SCHED]: Fix error handling while dumping
	actions
Date: Wed, 05 Jul 2006 09:35:27 -0400
Message-ID: <1152106527.5199.23.camel@jzny2>
References: <20060704220504.787776000@postel.suug.ch>
	 <20060704220550.406275000@postel.suug.ch>  <1152064058.5199.12.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:20408 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964861AbWGENfa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 09:35:30 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fy7XR-0007cO-Cg
	for netdev@vger.kernel.org; Wed, 05 Jul 2006 09:35:33 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <1152064058.5199.12.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas, 

Please resubmit this patch with changing -err to -1 (i.e a one liner)
I went back to about 2.6.10 and this is in there. I looked at my notes
and i cant see any reasoning to explain this. So it is a bug.
Is there a way to check whether this was a result of some other earlier
change or was always there?

I would say patch #1 deserves to go into stable; the others for later.
And thank you for your efforts.

cheers,
jamal

On Tue, 2006-04-07 at 21:47 -0400, jamal wrote:
> I need to stare at this one for longer than 1 minute and i dont have
> time right now; it does look strange (I am unsure what my thoughts were
> at that point with -err - or maybe that was a change made by someone
> else). 
> I dont have time until tommorow - but i would  think the better fix will
> be to change "return -err" to  "return -1"?
> 
> cheers,
> jamal 
> 
> On Wed, 2006-05-07 at 00:00 +0200, Thomas Graf wrote:
> > plain text document attachment (act_fix_dump_err_handling)
> > "return -err" and blindly inheriting the error code in the netlink
> > failure exception handler causes errors codes to be returned as
> > positive value therefore making them being ignored by the caller.
> > 
> > May lead to sending out incomplete netlink messages.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > 
> > 
> > Index: net-2.6.git/net/sched/act_api.c
> > ===================================================================
> > --- net-2.6.git.orig/net/sched/act_api.c
> > +++ net-2.6.git/net/sched/act_api.c
> > @@ -250,15 +250,17 @@ tcf_action_dump(struct sk_buff *skb, str
> >  		RTA_PUT(skb, a->order, 0, NULL);
> >  		err = tcf_action_dump_1(skb, a, bind, ref);
> >  		if (err < 0)
> > -			goto rtattr_failure;
> > +			goto errout;
> >  		r->rta_len = skb->tail - (u8*)r;
> >  	}
> >  
> >  	return 0;
> >  
> >  rtattr_failure:
> > +	err = -EINVAL;
> > +errout:
> >  	skb_trim(skb, b - skb->data);
> > -	return -err;
> > +	return err;
> >  }
> >  
> >  struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est,
> > 


