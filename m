From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipmr: ipmr_get_table() returns NULL
Date: Wed, 12 Jul 2017 11:02:53 +0300
Message-ID: <ceca8ed6-f40f-7b62-2681-61b7cf1eb9d2@cumulusnetworks.com>
References: <20170712075647.zyz6pkppyerl4ktf@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        Donald Sharp <sharpd@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:36606 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756893AbdGLIC4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 04:02:56 -0400
Received: by mail-wr0-f176.google.com with SMTP id c11so22286908wrc.3
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 01:02:55 -0700 (PDT)
In-Reply-To: <20170712075647.zyz6pkppyerl4ktf@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/17 10:56, Dan Carpenter wrote:
> The ipmr_get_table() function doesn't return error pointers it returns
> NULL on error.
> 
> Fixes: 4f75ba6982bc ("net: ipmr: Add ipmr_rtm_getroute")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index bb909f1d7537..06863ea3fc5b 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -2431,8 +2431,8 @@ static int ipmr_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>  	tableid = tb[RTA_TABLE] ? nla_get_u32(tb[RTA_TABLE]) : 0;
>  
>  	mrt = ipmr_get_table(net, tableid ? tableid : RT_TABLE_DEFAULT);
> -	if (IS_ERR(mrt)) {
> -		err = PTR_ERR(mrt);
> +	if (!mrt) {
> +		err = -ENOENT;
>  		goto errout_free;
>  	}
>  
> 

Good catch, ipmr_new_table() is the one that can return err ptr.

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
