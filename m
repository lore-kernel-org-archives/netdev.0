From: gerrit@erg.abdn.ac.uk
Subject: Re: [PATCH 02/86] dccp: revert buggy auto-loading of dccp module
Date: Tue, 2 Feb 2010 15:06:15 -0000 (GMT)
Message-ID: <53767.148.187.160.35.1265123175.squirrel@148.187.160.35>
References: <recent-dccp-bug-fixes-jan-2010>
    <1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
    <1265005087-5549-2-git-send-email-gerrit@erg.abdn.ac.uk>
    <1265005087-5549-3-git-send-email-gerrit@erg.abdn.ac.uk>
    <20100201122119.GC25094@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46054 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755114Ab0BBPGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 10:06:34 -0500
In-Reply-To: <20100201122119.GC25094@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> --- a/net/dccp/probe.c
> +++ b/net/dccp/probe.c
> @@ -161,7 +161,8 @@ static __init int dccpprobe_init(void)
>  	if (!proc_net_fops_create(&init_net, procname, S_IRUSR,
> &dccpprobe_fops))
>  		goto err0;
>
> -	ret = try_then_request_module((register_jprobe(&dccp_send_probe) == 0),
> +	try_then_request_module(
> +		((ret = register_jprobe(&dccp_send_probe)) == 0),
>  					"dccp");
>  	if (ret)
>  		goto err1;

Apologies for the late response -- delays are sometimes possible due to
day job. The only problem that I had with this patch was that it was
apparently not tested, causing the described problems.


> I've not tested it, but this should do it,
> without re-breaking the silent dependency.

I will test it and get back to you until tomorrow morning (GMT),
if it works I'll also push it out in the test tree.

Thanks a lot for getting back and devising a different route.


