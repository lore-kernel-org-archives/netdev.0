From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: Re: [PATCH 1/4] xfrm_hash: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 04:06:04 -0500 (EST)
Message-ID: <alpine.LFD.0.9999.0711260405110.362@localhost.localdomain>
References: <007c01c8300b$176975a0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:35497 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbXKZJIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 04:08:02 -0500
In-Reply-To: <007c01c8300b$176975a0$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Nov 2007, Joonwoo Park wrote:

> xfrm_hash: kmalloc + memset conversion to kzalloc
>
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
>
> Thanks.
> Joonwoo
>
> ---
> diff --git a/net/xfrm/xfrm_hash.c b/net/xfrm/xfrm_hash.c
> index 55ab579..37795bd 100644
> --- a/net/xfrm/xfrm_hash.c
> +++ b/net/xfrm/xfrm_hash.c
> @@ -17,16 +17,17 @@ struct hlist_head *xfrm_hash_alloc(unsigned int sz)
>  	struct hlist_head *n;
>
>  	if (sz <= PAGE_SIZE)
> -		n = kmalloc(sz, GFP_KERNEL);
> -	else if (hashdist)
> -		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
> -	else
> -		n = (struct hlist_head *)
> -			__get_free_pages(GFP_KERNEL | __GFP_NOWARN,
> -					 get_order(sz));
> -
> -	if (n)
> -		memset(n, 0, sz);
> +		n = kzalloc(sz, GFP_KERNEL);
> +	else {
> +		if (hashdist)

i believe the more common standard for the above is:

  else if (hashdist) {

to reduce the level of overall indentation, no?

rday

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
