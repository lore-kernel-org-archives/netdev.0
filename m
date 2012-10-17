From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] xfrm: use ISO C standard for array in linux/xfrm.h
Date: Wed, 17 Oct 2012 09:50:58 +0200
Message-ID: <507E6362.1080009@6wind.com>
References: <1350402153-3889-1-git-send-email-nicolas.dichtel@6wind.com> <20121017054343.GA12671@secunet.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	davem@davemloft.net
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38632 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403Ab2JQHvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 03:51:02 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so3876621eek.19
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 00:51:01 -0700 (PDT)
In-Reply-To: <20121017054343.GA12671@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/10/2012 07:43, Steffen Klassert a =E9crit :
> On Tue, Oct 16, 2012 at 05:42:33PM +0200, nicolas.dichtel@6wind.com w=
rote:
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>
>> Use the ISO C standard compliant form instead of the gcc extension.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   include/uapi/linux/xfrm.h | 10 +++++-----
>>   1 file changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
>> index 28e493b..6a6a605 100644
>> --- a/include/uapi/linux/xfrm.h
>> +++ b/include/uapi/linux/xfrm.h
>> @@ -30,7 +30,7 @@ struct xfrm_sec_ctx {
>>   	__u8	ctx_alg;
>>   	__u16	ctx_len;
>>   	__u32	ctx_sid;
>> -	char	ctx_str[0];
>> +	char	ctx_str[];
>
> Hm, what's the benefit of such a change? The kernel source is full
> of these foo[0] type arrays. I don't see a reason to change this
> just for xfrm.
>
We got a problem with "ip xfrm state add" when compiled with gcc 4.4.6.
Error was "*** buffer overflow detected ***: ip terminated", because wh=
en we try=20
to copy the key in struct xfrm_algo, the function strncpy() calls some =
builtin=20
checks about the size of the destination buffer, which is 0. With the s=
tandard=20
notation, there is no problem.

With gcc 4.7.0, there is no problem, I don't know exactly which version=
 of gcc=20
triggers the problem.
