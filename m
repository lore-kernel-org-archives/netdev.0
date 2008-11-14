From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: speedup dst_release()
Date: Fri, 14 Nov 2008 12:36:13 +0300
Message-ID: <20081114093613.GA2834@x200.localdomain>
References: <491D323B.9030802@cosmosbay.com> <20081114.005437.09284570.davem@davemloft.net> <491D3F18.5030505@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:58991 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbYKNJco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 04:32:44 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1588682ugf.37
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 01:32:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <491D3F18.5030505@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2008 at 10:04:24AM +0100, Eric Dumazet wrote:
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Fri, 14 Nov 2008 09:09:31 +0100
>>
>>> During tbench/oprofile sessions, I found that dst_release() was in =
third position.
>>  ...
>>> Instead of first checking the refcount value, then decrement it,
>>> we use atomic_dec_return() to help CPU to make the right memory tra=
nsaction
>>> (ie getting the cache line in exclusive mode)
>>  ...
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>
>> This looks great, applied, thanks Eric.
>>
>
> Thanks David
>
>
> I think I understood some regressions here on 32bits=20
>
> offsetof(struct dst_entry, __refcnt) is 0x7c again !!!
>
> This is really really bad for performance
>
> I believe this comes from a patch from Alexey Dobriyan
> (commit def8b4faff5ca349beafbbfeb2c51f3602a6ef3a
> net: reduce structures when XFRM=3Dn)

Ick.

> This kills effort from Zhang Yanmin (and me...)
>
> (commit f1dd9c379cac7d5a76259e7dffcd5f8edc697d17
> [NET]: Fix tbench regression in 2.6.25-rc1)
>
>
> Really we must find something so that this damned __refcnt is startin=
g at 0x80

Make it last member?
