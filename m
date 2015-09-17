From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next] net: only check perm protocol when
 register proto
Date: Thu, 17 Sep 2015 16:20:41 -0700 (PDT)
Message-ID: <20150917.162041.2147817140272126896.davem@davemloft.net>
References: <1442276045-4233-1-git-send-email-martinbj2008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	baker.kernel@gmail.com
To: martinbj2008@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442276045-4233-1-git-send-email-martinbj2008@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: martinbj2008@gmail.com
Date: Tue, 15 Sep 2015 08:14:05 +0800

> @@ -1043,22 +1043,16 @@ void inet_register_protosw(struct inet_protosw *p)
>  		goto out_illegal;
>  
>  	/* If we are trying to override a permanent protocol, bail. */
> -	answer = NULL;
>  	last_perm = &inetsw[p->type];
>  	list_for_each(lh, &inetsw[p->type]) {
>  		answer = list_entry(lh, struct inet_protosw, list);
> -
>  		/* Check only the non-wild match. */
> -		if (INET_PROTOSW_PERMANENT & answer->flags) {
> -			if (protocol == answer->protocol)
> +		if ((INET_PROTOSW_PERMANENT & answer->flags) == 0)
>  				break;
> -			last_perm = lh;

Well, if you're going to do this, you need to fix up the indentation
of that "break;" statement.
