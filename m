From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 02/86] dccp: revert buggy auto-loading of dccp module
Date: Tue, 2 Feb 2010 10:39:29 -0500
Message-ID: <20100202153929.GA12697@hmsreliant.think-freely.org>
References: <recent-dccp-bug-fixes-jan-2010>
 <1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1265005087-5549-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1265005087-5549-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <20100201122119.GC25094@hmsreliant.think-freely.org>
 <53767.148.187.160.35.1265123175.squirrel@148.187.160.35>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46545 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756448Ab0BBPje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 10:39:34 -0500
Content-Disposition: inline
In-Reply-To: <53767.148.187.160.35.1265123175.squirrel@148.187.160.35>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 02, 2010 at 03:06:15PM -0000, gerrit@erg.abdn.ac.uk wrote:
> > --- a/net/dccp/probe.c
> > +++ b/net/dccp/probe.c
> > @@ -161,7 +161,8 @@ static __init int dccpprobe_init(void)
> >  	if (!proc_net_fops_create(&init_net, procname, S_IRUSR,
> > &dccpprobe_fops))
> >  		goto err0;
> >
> > -	ret = try_then_request_module((register_jprobe(&dccp_send_probe) == 0),
> > +	try_then_request_module(
> > +		((ret = register_jprobe(&dccp_send_probe)) == 0),
> >  					"dccp");
> >  	if (ret)
> >  		goto err1;
> 
> Apologies for the late response -- delays are sometimes possible due to
> day job. The only problem that I had with this patch was that it was
> apparently not tested, causing the described problems.
> 
> 
> > I've not tested it, but this should do it,
> > without re-breaking the silent dependency.
> 
> I will test it and get back to you until tomorrow morning (GMT),
> if it works I'll also push it out in the test tree.
> 
> Thanks a lot for getting back and devising a different route.
> 
Thanks, and apologies for being brusque.  I just didn't want to fix what is
clearly a problem in what you describe by rebreaking a previously seen problem.
I expect this should work just fine.  Let me know if it doesn't and I'll
resurrect my test bed here and take a look
Neil

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
