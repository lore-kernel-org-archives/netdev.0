From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] dccp: Fix compile warning in probe code.
Date: Fri, 2 Dec 2011 19:52:05 -0700
Message-ID: <20111203025205.GA4437@gerrit.erg.abdn.ac.uk>
References: <20111201.144650.173157123252154314.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33854 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755508Ab1LCCwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 21:52:14 -0500
Content-Disposition: inline
In-Reply-To: <20111201.144650.173157123252154314.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

I have compiled and tested this and added the patch to the test tree.
Thanks for the improvement.

| --- a/net/dccp/probe.c
| +++ b/net/dccp/probe.c
| @@ -152,6 +152,17 @@ static const struct file_operations dccpprobe_fops = {
|  	.llseek  = noop_llseek,
|  };
|  
| +static __init int setup_jprobe(void)
| +{
| +	int ret = register_jprobe(&dccp_send_probe);
| +
| +	if (ret) {
| +		request_module("dccp");
| +		ret = register_jprobe(&dccp_send_probe);
| +	}
| +	return ret;
| +}
| +
|  static __init int dccpprobe_init(void)
|  {
|  	int ret = -ENOMEM;
| @@ -163,8 +174,7 @@ static __init int dccpprobe_init(void)
|  	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &dccpprobe_fops))
|  		goto err0;
|  
| -	try_then_request_module((ret = register_jprobe(&dccp_send_probe)) == 0,
| -				"dccp");
| +	ret = setup_jprobe();
|  	if (ret)
|  		goto err1;
|  
| -- 
| 1.7.7.3
| 
| 

-- 
