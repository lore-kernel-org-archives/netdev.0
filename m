From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v8] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 25 Nov 2015 13:04:43 +0000
Message-ID: <yw1xy4dmp6vo.fsf@unicorn.mansr.com>
References: <1447938180-19651-1-git-send-email-mans@mansr.com>
	<5655AB63.40204@free.fr> <yw1x37vuqmcy.fsf@unicorn.mansr.com>
	<5655B0DF.8060000@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:41252 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752591AbbKYNEp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 08:04:45 -0500
In-Reply-To: <5655B0DF.8060000@free.fr> (Mason's message of "Wed, 25 Nov 2015
	14:00:15 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 25/11/2015 13:45, M=E5ns Rullg=E5rd wrote:
>
>> Mason wrote:
>>=20
>>> On 19/11/2015 14:02, Mans Rullgard wrote:
>>>
>>>> +	if (dma_mapping_error(&dev->dev, dma_addr)) {
>>>> +		skb_free_frag(data);
>>>> +		return -ENOMEM;
>>>> +	}
>>>
>>> I'm back-porting this driver to 4.1
>>>
>>> skb_free_frag() was introduced in 4.2 by 181edb2bfa22b IIUC.
>>>
>>> +static inline void skb_free_frag(void *addr)
>>> +{
>>> +       __free_page_frag(addr);
>>> +}
>>>
>>> Should I just copy the definition of __free_page_frag() ?
>>=20
>> Looks like it ought to work.  Try and find out.  Not that you'll eve=
r
>> hit that error condition unless you fake it.
>
> Turns out __free_pages_ok() is static and I'd rather not touch
> mm/page_alloc.c in my back-port.
>
> Since you say the error condition is rare, I think I'll go with
> the code that 181edb2bfa22b replaced (put_page, IIUC).
>
> #include <linux/version.h>
> #if LINUX_VERSION_CODE < KERNEL_VERSION(4,2,0)
> #define skb_free_frag(data) put_page(virt_to_head_page(data))
> #else
> #error DELETE ME NOW (see commit 181edb2bfa22b)
> #endif

You can simply put_page(page) instead since we already have the
virt_to_head_page() a few lines up.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
