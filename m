From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] eexpress: Read buffer overflow
Date: Wed, 29 Jul 2009 12:29:53 +0000
Message-ID: <20090729122953.GC5490@ff.dom.local>
References: <4A703D65.7010805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f221.google.com ([209.85.218.221]:37445 "EHLO
	mail-bw0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304AbZG2M37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 08:29:59 -0400
Received: by bwz21 with SMTP id 21so653879bwz.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 05:29:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A703D65.7010805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29-07-2009 14:15, Roel Kluin wrote:
...
> 3 lines it is, but scripts/checkpatch.pl doesn't like it.
> 
> diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
> index 1686dca..7b40014 100644
> --- a/drivers/net/eexpress.c
> +++ b/drivers/net/eexpress.c
> @@ -1474,13 +1474,13 @@ static void eexp_hw_init586(struct net_device *dev)
>  	outw(0x0000, ioaddr + 0x800c);
>  	outw(0x0000, ioaddr + 0x800e);
>  
> -	for (i = 0; i < (sizeof(start_code)); i+=32) {
> +	for (i = 0; i < ARRAY_SIZE(start_code); i+=32) {
>  		int j;
>  		outw(i, ioaddr + SM_PTR);
> -		for (j = 0; j < 16; j+=2)
> +		for (j = 0; j < 16 && (i+j)/2 < ARRAY_SIZE(start_code); j+=2)
>  			outw(start_code[(i+j)/2],
>  			     ioaddr+0x4000+j);
> -		for (j = 0; j < 16; j+=2)
> +		for (j = 0; j < 16 && (i+j+16)/2 < ARRAY_SIZE(start_code); j+=2)
>  			outw(start_code[(i+j+16)/2],
>  			     ioaddr+0x8000+j);
>  	}

Now you seem to make my previous math working :-)

>> (max) i = 64, (max) j = 14, (64+14+16)/2 = 47 < 69, so it seems to copy
>> less than its size?

Jarek P.
