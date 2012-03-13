From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Tue, 13 Mar 2012 00:21:55 -0700
Message-ID: <CAHo-Ooyi_NOZeT978EjUaPSYBMco9FmQh8uNpCLr-6owfYyMTQ@mail.gmail.com>
References: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
	<20120312.225435.1585479447873313061.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35257 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503Ab2CMHV4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 03:21:56 -0400
Received: by wibhq7 with SMTP id hq7so331730wib.1
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 00:21:55 -0700 (PDT)
In-Reply-To: <20120312.225435.1585479447873313061.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If I understand correctly, you're suggesting to go with

return ((26468 >> (i+i)) & 3) - 1;

correct?

2012/3/12 David Miller <davem@davemloft.net>:
> From: Maciej =C5=BBenczykowski <zenczykowski@gmail.com>
> Date: Mon, 12 Mar 2012 22:12:21 -0700
>
>> From: Maciej =C5=BBenczykowski <maze@google.com>
>>
>> See ffs(x) definition in arch/x86/include/asm/bitops.h
>>
>> =C2=A0 ffs - find first set bit in word
>>
>> =C2=A0 ffs(value) returns 0 if value is 0 or the position of the fir=
st
>> =C2=A0 set bit if value is nonzero. The first (least significant) bi=
t
>> =C2=A0 is at position 1.
>>
>> On x86_64 ffs(x) is effectively:
>> =C2=A0 Z :=3D -1
>> =C2=A0 BSFL X, Z
>> =C2=A0 return Z + 1
>>
>> Since we subtract one, we effectively end up with:
>> =C2=A0 Z :=3D -1
>> =C2=A0 BSFL X, Z
>> =C2=A0 return Z
>>
>> This is certainly more readable than the open coded array that
>> was there before, supports an easier change in the number of bands,
>> and is probably faster to boot (no memory lookup).
>>
>> However, on other architectures ffs() might not be so pretty,
>> hence use a clever arithmetic hack on other archs.
>> Unfortunately it only support 3 bands.
>>
>> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
>
> It's about the same cost, the non-ffs() version, so I would just
> use that for now. =C2=A0Conditionalized code is such a pain in the bu=
tt.
>
