From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SG_IO with >4k buffer size to iscsi sg device causes "Bad page" panic
Date: Fri, 08 Jun 2007 16:22:12 +1000
Message-ID: <E1HwXrQ-0005Rn-00@gondolin.me.apana.org.au>
References: <0F08E10B769EAF4EA2C43A573B8CC87FB572B9@NAMAIL3.ad.lsil.com>
Cc: open-iscsi@googlegroups.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-iscsi-devel@lists.sourceforge.net, michaelc@cs.wisc.edu,
	dougg@torque.net, James.Bottomley@steeleye.com
To: Yanling.Qi@lsi.com (Qi, Yanling)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2296 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754421AbXFHGWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 02:22:54 -0400
In-Reply-To: <0F08E10B769EAF4EA2C43A573B8CC87FB572B9@NAMAIL3.ad.lsil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please don't drop CCs.

Qi, Yanling <Yanling.Qi@lsi.com> wrote:
>
>> Qi, Yanling <Yanling.Qi@lsi.com> wrote:
>> > @@ -2571,6 +2572,13 @@ sg_page_malloc(int rqSz, int lowDma, int
>> >                resp = (char *) __get_free_pages(page_mask, order);
>> > /* try half */
>> >                resSz = a_size;
>> >        }
>> > +       tmppage = virt_to_page(resp);
>> > +       for( m = PAGE_SIZE; m < resSz; m += PAGE_SIZE )
>> > +       {
>> > +               tmppage++;
>> > +               SetPageReserved(tmppage);
>> > +       }
>> > +
>> 
> [Qi, Yanling]
> If I do a get_page() at sg_page_malloc() time and then do a put_page()
> at sg_page_free() time, I worry about a race condition that the page
> gets re-used before calling free_pages().

Could you explain what is going to cause this page to be reused if it
has a non-zero reference count?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
