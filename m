From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH v8] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 25 Nov 2015 13:45:07 +0100
Message-ID: <5655AD53.30805@free.fr>
References: <1447938180-19651-1-git-send-email-mans@mansr.com>
 <5655AB63.40204@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:9941 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563AbbKYMpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 07:45:13 -0500
In-Reply-To: <5655AB63.40204@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Using different address for Alexander ]

On 25/11/2015 13:36, Mason wrote:

> On 19/11/2015 14:02, Mans Rullgard wrote:
> 
>> +	if (dma_mapping_error(&dev->dev, dma_addr)) {
>> +		skb_free_frag(data);
>> +		return -ENOMEM;
>> +	}
> 
> I'm back-porting this driver to 4.1
> 
> skb_free_frag() was introduced in 4.2 by 181edb2bfa22b IIUC.
> 
> +static inline void skb_free_frag(void *addr)
> +{
> +       __free_page_frag(addr);
> +}
> 
> Should I just copy the definition of __free_page_frag() ?
> 
> /*
>  * Frees a page fragment allocated out of either a compound or order 0 page.
>  */
> void __free_page_frag(void *addr)
> {
> 	struct page *page = virt_to_head_page(addr);
> 
> 	if (unlikely(put_page_testzero(page)))
> 		__free_pages_ok(page, compound_order(page));
> }
