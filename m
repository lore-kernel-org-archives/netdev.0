From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] fix potential wild pointer when NIC is dying
Date: Wed, 14 Apr 2010 12:24:22 +0800
Message-ID: <m2m412e6f7f1004132124y9ff2eeddwa2bbcaaa5d1f894f@mail.gmail.com>
References: <1271247503-2973-1-git-send-email-xiaosuo@gmail.com>
	<1271218986.1555.29.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.211.194]:57820 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab0DNEYn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 00:24:43 -0400
Received: by ywh32 with SMTP id 32so2655876ywh.33
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 21:24:42 -0700 (PDT)
In-Reply-To: <1271218986.1555.29.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 14, 2010 at 12:23 PM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2010-04-14 at 20:18 +0800, Changli Gao wrote:
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index a10a216..fe4a821 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
> []
>> -static void flush_backlog(void *arg)
>> +static int flush_backlog(void *arg)
>
> Why change this to return int?
>
>> + =C2=A0 =C2=A0 return 0;
>
> It seems to always return 0.
>
>

Keep stop_machine() happy.
int stop_machine(int (*fn)(void *), void *data, const struct cpumask *c=
pus);

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
