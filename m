From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] ipv6: fix compiler warning in ipv6_exthdrs_len
Date: Mon, 16 Dec 2013 00:20:22 +0800
Message-ID: <CAPshTCj38XqrAMTKnGhw1bdWWrhHbzXpT8FNtDwd6_kJgLoeDg@mail.gmail.com>
References: <1386824025-27413-1-git-send-email-hkchu@google.com>
	<20131214062929.GA23563@order.stressinduktion.org>
	<20131214.020211.969354536190248209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f50.google.com ([209.85.128.50]:53390 "EHLO
	mail-qe0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab3LOQUX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 11:20:23 -0500
Received: by mail-qe0-f50.google.com with SMTP id 1so3159604qec.37
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 08:20:23 -0800 (PST)
In-Reply-To: <20131214.020211.969354536190248209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 14, 2013 at 3:02 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sat, 14 Dec 2013 07:29:29 +0100
>
>> Commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36 ("net-gro: Prepare G=
RO
>> stack for the upcoming tunneling support") used an uninitialized var=
iable
>> which leads to the following compiler warning:
>>
>> net/ipv6/ip6_offload.c: In function =91ipv6_gro_complete=92:
>> net/ipv6/ip6_offload.c:178:24: warning: =91optlen=92 may be used uni=
nitialized in this function [-Wmaybe-uninitialized]
>>     opth =3D (void *)opth + optlen;
>>                         ^
>> net/ipv6/ip6_offload.c:164:22: note: =91optlen=92 was declared here
>>   int len =3D 0, proto, optlen;
>>                       ^
>> Fix it up.
>>
>> Cc: Jerry Chu <hkchu@google.com>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> Applied.

Please back out the above "fix" - it actually breaks the original code =
because
the fix will cause exthdrs_len to be one optlen short.

There was no bug in the original code, just the compiler warning (and I=
 do not
get any warning, although I admit I did not run with the -W flag).

In any case I will submit a revision shortly that will silent any
warning if exists.

Jerry
