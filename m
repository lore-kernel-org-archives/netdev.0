From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V2 3/3] net: Add GRO support for vxlan traffic
Date: Tue, 7 Jan 2014 22:12:06 +0200
Message-ID: <CAJZOPZ+_1z+Qq0U0XnEAMygXMXTivN7giZ5P-QH-L_dkz2_hFw@mail.gmail.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	<1389108594-665-4-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx-fUe_VbUUnjEVXeJO=87yypoDuMfoctO0Q3nMx+6UZFA@mail.gmail.com>
	<CAJZOPZKHC1t6tGjZ9ZyTD912-5Bw_Vtin8N2MnqkOi4W2wPrzA@mail.gmail.com>
	<1389124947.26646.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tom Herbert <therbert@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35350 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbaAGUMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:12:07 -0500
Received: by mail-pd0-f170.google.com with SMTP id g10so804350pdj.29
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 12:12:07 -0800 (PST)
In-Reply-To: <1389124947.26646.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 7, 2014 at 10:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-01-07 at 21:43 +0200, Or Gerlitz wrote:
>> On Tue, Jan 7, 2014 at 8:08 PM, Tom Herbert <therbert@google.com> wrote:
>
>> > Why ^ instead of != ?
>>
>> The XOR approach is very popular in the GRO stack, e.g see the IPv4 chain
>> of inet_gro_receive() && tcp_gro_receive(), I guess this might relates
>> to more efficient assembly code for ^ vs. != and/or the fast/elegant
>> transitive nature of that operator
>
> This trick is only needed/used when many compares are folded into a
> single conditional :
>
> if (a->f1 != b->f1 || a->f2 != b->f2)
>
> ->
>
> if (((a->f1 ^ b->f1) | (a->f2 ^ b->f2)) != 0)
>
> Please do not use XOR for a single compare.

OK, but just out of curiosity -- what's the reasoning? clarity or
efficiency or both?
>
>
>
