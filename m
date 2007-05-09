From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SG_IO with >4k buffer size to iscsi sg device causes "Bad page" panic
Date: Thu, 10 May 2007 09:38:53 +1000
Message-ID: <E1HlvkD-0004zY-00@gondolin.me.apana.org.au>
References: <0F08E10B769EAF4EA2C43A573B8CC87FB106C0@NAMAIL3.ad.lsil.com>
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com,
	linux-iscsi-devel@lists.sourceforge.net, Yanling.Qi@lsi.com,
	michaelc@cs.wisc.edu, dougg@torque.net,
	James.Bottomley@steeleye.com
To: Yanling.Qi@lsi.com (Qi, Yanling)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2764 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756894AbXEIXjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 19:39:33 -0400
In-Reply-To: <0F08E10B769EAF4EA2C43A573B8CC87FB106C0@NAMAIL3.ad.lsil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Qi, Yanling <Yanling.Qi@lsi.com> wrote:
> @@ -2571,6 +2572,13 @@ sg_page_malloc(int rqSz, int lowDma, int
>                resp = (char *) __get_free_pages(page_mask, order);
> /* try half */
>                resSz = a_size;
>        }
> +       tmppage = virt_to_page(resp);
> +       for( m = PAGE_SIZE; m < resSz; m += PAGE_SIZE )
> +       {
> +               tmppage++;
> +               SetPageReserved(tmppage);
> +       }
> +

Why not just increase the page use count?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
