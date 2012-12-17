From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: XFRM: Could we change ESP padding?
Date: Mon, 17 Dec 2012 14:56:47 +0800
Message-ID: <CAJFZqHzCEJyvxc2NNh3_U8oT9Uh94N6EXLb4UA=twvVcVnEd5w@mail.gmail.com>
References: <CAJFZqHzDDtUacnQzd-gcS8JBvPdgspozWkUFOogS4nDmvZz7rg@mail.gmail.com>
	<20121217064302.GK18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:56828 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab2LQG4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 01:56:49 -0500
Received: by mail-vb0-f46.google.com with SMTP id b13so6593299vby.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 22:56:48 -0800 (PST)
In-Reply-To: <20121217064302.GK18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/17 Steffen Klassert <steffen.klassert@secunet.com>:
> On Mon, Dec 17, 2012 at 11:28:05AM +0800, RongQing Li wrote:
>> Hi:
>>
>> setkey has the below parameter, but this parameter seems not be
>> implemented in kernel and userspace,
>>
>>      -f pad_option  defines the content of the ESP padding.
>> pad_option is one of following:
>>         zero-pad    All the paddings are zero.
>>         random-pad  A series of randomized values are used.
>>         seq-pad     A series of sequential increasing numbers
>>  started from 1 are used.
>>
>
> We can not implement this. As you already mentioned, RFC 4303
> makes strong statements on how the padding bytes are initialized.
> An IPsec implementation that checks the padding bytes would drop our
> packets if we don't use the padding method described in RFC 4303.
>
>>
>> and kernel seems not inspect the ESP padding content too, the result
>> is the packets are not dropped even if they are with a wrong pad
>> content(not a monotonically increasing sequence).
>>
>>
>> Could anyone tell me why, bad description in RFC, performance, lack time,
>> or other reason? Thanks very much!
>>
>
> RFC 4303 says that the receiver should inspect the padding field,
> so we are free to do it or not. You can find a comment that explains
> why we don't do it in the esp_input_done2() function ;-)
>
Thanks.

But I see BSD has implemented it, and cisco device has similar implmentation.

http://fxr.watson.org/fxr/source/netipsec/xform_esp.c

-RongQing
