From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] cxgb4: Add debugfs entry to enable/disable
 backdoor access
Date: Mon, 20 Jul 2015 15:13:33 +0300
Message-ID: <55ACE5ED.1030304@cogentembedded.com>
References: <1437404051-7020-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:32846 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbbGTMNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 08:13:36 -0400
Received: by lbbyj8 with SMTP id yj8so93986959lbb.0
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 05:13:34 -0700 (PDT)
In-Reply-To: <1437404051-7020-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/20/2015 5:54 PM, Hariprasad Shenai wrote:

> Add debugfs entry 'use_backdoor' to enable/disable backdoor access
> to read sge context. By default, we read sge context's via firmware. In
> case of FW issues, one can enable backdoor access via debugfs to dump
> sge context for debugging purpose.

> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
[...]
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> index b135d05..5b525a7 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> @@ -2386,8 +2386,11 @@ int t4_setup_debugfs(struct adapter *adap)
>   					EXT_MEM_SIZE_G(size));
>   	}
>
> -	de = debugfs_create_file_size("flash", S_IRUSR, adap->debugfs_root, adap,
> -				      &flash_debugfs_fops, adap->params.sf_size);
> +	de = debugfs_create_file_size("flash", S_IRUSR, adap->debugfs_root,
> +				      adap, &flash_debugfs_fops,
> +				      adap->params.sf_size);

    What was the point reformatting this call?

[...]
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> index 1e6597d..f8f446e 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> @@ -3689,6 +3689,11 @@ int t4_read_rss(struct adapter *adapter, u16 *map)
>   	return 0;
>   }
>
> +static unsigned int t4_use_ldst(struct adapter *adap)
> +{
> +	return (adap->flags & FW_OK) || (!adap->use_bd);

    Second parens not neeeded.

[...]

WBR, Sergei
