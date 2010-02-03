From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 1/1] dccp: fix auto-loading of dccp(_probe)
Date: Wed, 3 Feb 2010 06:58:40 -0500
Message-ID: <20100203115840.GA651@hmsreliant.think-freely.org>
References: <1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1265005087-5549-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1265005087-5549-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <20100201122119.GC25094@hmsreliant.think-freely.org>
 <53767.148.187.160.35.1265123175.squirrel@148.187.160.35>
 <20100202153929.GA12697@hmsreliant.think-freely.org>
 <20100203061656.GA5415@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36396 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab0BCL6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 06:58:46 -0500
Content-Disposition: inline
In-Reply-To: <20100203061656.GA5415@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2010 at 07:16:56AM +0100, Gerrit Renker wrote:
> Hi Neil,
> 
> I have tested your patch, it works fine thanks to the repeated execution of the macro
> argument. I have reformatted it, removing the inner parentheses, which I think is
> justified since macros copy their arguments in full. Also converted your email to a
> drafted commit message. Due to this, have not copied your signed-off -- if you are
> ok, please add, this should be submitted asap.
> 
Understood, and thank you.  This looks fine to me

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

> >>>>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> dccp: fix loading of dccp_probe
> 
> This fixes commit (38ff3e6bb987ec583268da8eb22628293095d43b) ("dccp_probe:
> Fix module load dependencies between dccp and dccp_probe", from 15 Jan).
> 
> It fixes the construction of the first argument of try_then_request_module(),
> where only valid return codes from the first argument should be returned.
> 
> What we do now is assign the result of register_jprobe() to ret, without
> the side effect of the comparison.
> 
> Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/probe.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- a/net/dccp/probe.c
> +++ b/net/dccp/probe.c
> @@ -161,8 +161,8 @@ static __init int dccpprobe_init(void)
>  	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &dccpprobe_fops))
>  		goto err0;
>  
> -	ret = try_then_request_module((register_jprobe(&dccp_send_probe) == 0),
> -					"dccp");
> +	try_then_request_module((ret = register_jprobe(&dccp_send_probe)) == 0,
> +				"dccp");
>  	if (ret)
>  		goto err1;
>  
> 
