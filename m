From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v8] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 25 Nov 2015 12:45:01 +0000
Message-ID: <yw1x37vuqmcy.fsf@unicorn.mansr.com>
References: <1447938180-19651-1-git-send-email-mans@mansr.com>
	<5655AB63.40204@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:41215 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753434AbbKYMpD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 07:45:03 -0500
In-Reply-To: <5655AB63.40204@free.fr> (Mason's message of "Wed, 25 Nov 2015
	13:36:51 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

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

Looks like it ought to work.  Try and find out.  Not that you'll ever
hit that error condition unless you fake it.

> /*
>  * Frees a page fragment allocated out of either a compound or order =
0 page.
>  */
> void __free_page_frag(void *addr)
> {
> 	struct page *page =3D virt_to_head_page(addr);
>
> 	if (unlikely(put_page_testzero(page)))
> 		__free_pages_ok(page, compound_order(page));
> }
>
> Regards.
>

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
