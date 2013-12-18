From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH 1/1][net-next] dccp: catch failed request_module call
 in dccp_probe init
Date: Wed, 18 Dec 2013 10:38:36 +0800
Message-ID: <52B10AAC.3070400@huawei.com>
References: <52B043D9.9090808@huawei.com> <20131217192433.168b39ef@liptov.cs.ualberta.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <dccp@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:51678 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3LRCi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 21:38:57 -0500
In-Reply-To: <20131217192433.168b39ef@liptov.cs.ualberta.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/18 10:24, Gerrit Renker wrote:
> Hi Wang,
> 
> thank you for the patch, please find refactored version below, changes are
>  (a) if request_module fails, return its error code instead of the previous ret,
>  (b) refactor code -- setup_jprobe becomes superfluous.
> 
> Please add your signed off if ok, since it is essentially your patch.
> 
>>>>>>>>>>>>>>>>>>>>>>>> Wang's patch revised <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> dccp: catch failed request_module call in dccp_probe init
> 
> Check the return value of request_module during dccp_probe initialisation,
> bail out if that call fails.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/probe.c |   19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)
> 
> --- a/net/dccp/probe.c
> +++ b/net/dccp/probe.c
> @@ -152,17 +152,6 @@ static const struct file_operations dccp
>  	.llseek  = noop_llseek,
>  };
>  
> -static __init int setup_jprobe(void)
> -{
> -	int ret = register_jprobe(&dccp_send_probe);
> -
> -	if (ret) {
> -		request_module("dccp");
> -		ret = register_jprobe(&dccp_send_probe);
> -	}
> -	return ret;
> -}
> -
>  static __init int dccpprobe_init(void)
>  {
>  	int ret = -ENOMEM;
> @@ -174,7 +163,13 @@ static __init int dccpprobe_init(void)
>  	if (!proc_create(procname, S_IRUSR, init_net.proc_net, &dccpprobe_fops))
>  		goto err0;
>  
> -	ret = setup_jprobe();
> +	ret = register_jprobe(&dccp_send_probe);
> +	if (ret) {
> +		ret = request_module("dccp");
> +		if (!ret)
> +			ret = register_jprobe(&dccp_send_probe);
> +	}
> +
>  	if (ret)
>  		goto err1;
>  
> 
> 

It is OK.
Thanks.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
