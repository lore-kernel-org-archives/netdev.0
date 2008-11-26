From: steve@chygwyn.com
Subject: Re: [PATCH-mm 8/8] decnet: remove private wrappers of endian
	helpers
Date: Wed, 26 Nov 2008 21:33:59 +0000
Message-ID: <20081126213359.GA20782@fogou.chygwyn.com>
References: <1227733974.5511.130.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:34801 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189AbYKZWVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 17:21:11 -0500
Content-Disposition: inline
In-Reply-To: <1227733974.5511.130.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Nov 26, 2008 at 01:12:54PM -0800, Harvey Harrison wrote:
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
[snip]
> diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
> index 3012511..c378be7 100644
> --- a/include/net/dn_fib.h
> +++ b/include/net/dn_fib.h
> @@ -181,9 +181,9 @@ static inline void dn_fib_res_put(struct dn_fib_res *res)
>  
>  static inline __le16 dnet_make_mask(int n)
>  {
> -        if (n)
> -                return dn_htons(~((1<<(16-n))-1));
> -        return 0;
> +	if (n)
> +		return cpu_to_le16(~((1 << (16 - n)) - 1));
> +	return cpu_to_le16(0);
>  }
You don't need to convert 0.

[snip]
>  
> @@ -327,7 +327,7 @@ int dn_username2sockaddr(unsigned char *data, int len, struct sockaddr_dn *sdn,
>  	int namel = 12;
>  
>  	sdn->sdn_objnum = 0;
> -	sdn->sdn_objnamel = dn_htons(0);
> +	sdn->sdn_objnamel = cpu_to_le16(0);
Again, no need to convert 0 even though I did :-)

Otherwise the patch looks good.

Reviewed-by: Steven Whitehouse <swhiteho@redhat.com>


Steve.

