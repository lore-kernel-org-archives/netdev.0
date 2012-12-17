From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] netlink: align attributes on 64-bits
Date: Mon, 17 Dec 2012 17:53:46 +0100
Message-ID: <50CF4E1A.1060207@6wind.com>
References: <20121211184013.GD27746@casper.infradead.org> <1355491002-3931-1-git-send-email-nicolas.dichtel@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F0@saturn3.aculab.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tgraf@suug.ch, netdev@vger.kernel.org, davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55277 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179Ab2LQQxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 11:53:51 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so2892871bkw.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 08:53:50 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70F0@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/12/2012 10:59, David Laight a =E9crit :
>> -	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
>> +	int align =3D IS_ALIGNED((unsigned long)skb_tail_pointer(skb), siz=
eof(void *)) ? 0 : 4;
>> +
>> +	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen) + align))
>>   		return -EMSGSIZE;
>>
>> +	if (align) {
>> +		/* Goal is to add an attribute with size 4. We know that
>> +		 * NLA_HDRLEN is 4, hence payload is 0.
>> +		 */
>> +		__nla_reserve(skb, 0, 0);
>> +	}
>> +
>
> Shouldn't the size of the dummy parameter be based on the value
> of 'align' - and that be based on the amount of padding needed?
>
Align is 4 or 0. Instead of the comment and 0, I can put 'NLA_HDRLEN - =
align',=20
which will always be 0, because we made this patch because we don't wan=
t to=20
change values like NLA_HDRLEN, because many user apps have these values=
=20
/structures hardcoded.

> That aligns the write pointer, what guarantees the alignment of
> the start of the buffer - so that the reader will find aligned data?
As Thomas said, skb->head will be aligned, am I wrong?

>
> What guarantees that the reader will read the data into an
> 8-byte aligned buffer.
>
> There is also the lurking issue of items that require more
> than 8-byte alignment.
> (x86/amd64 requires 16-byte alignment for 16-byte SSE2 regs and
> 32-byte alignment for the AVX regs.)
>
> Will anyone ever want to put such items into a netlink message?
>
> 	David
