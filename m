From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/2] af_packet: use vmalloc_to_page() instead for the
 addresss returned by vmalloc()
Date: Wed, 1 Dec 2010 22:16:20 +0800
Message-ID: <AANLkTinViD=WpwUFUDF6mKbc-Cap_Tg=SXwOjVQ=5u4B@mail.gmail.com>
References: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com>
 <1291126341.2904.82.camel@edumazet-laptop> <20101130143720.GA6017@hmsreliant.think-freely.org>
 <AANLkTim7SSRMkhc_eMz+Bk12kAwfG==j-dH4NOPu-uS2@mail.gmail.com> <1291210691.2856.740.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42973 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab0LAOQm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 09:16:42 -0500
Received: by gwj20 with SMTP id 20so3398246gwj.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 06:16:41 -0800 (PST)
In-Reply-To: <1291210691.2856.740.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 1, 2010 at 9:38 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 01 d=E9cembre 2010 =E0 21:05 +0800, Changli Gao a =E9crit=
 :
>> On Tue, Nov 30, 2010 at 10:37 PM, Neil Horman <nhorman@tuxdriver.com=
> wrote:
>> > Off the top of my head, I would think that pgv_to_page could be pr=
ototyped such
>> > that it could accept addr, offset and struct page ** arguments. =A0=
That way we can
>> > track the current page that we're mapped to, lowering the number o=
f calls to
>> > vmalloc_to_page, and we can still use an increment like we do abov=
e (as long as
>> > its wrapped in a subsequent call to pgv_to_page)
>>
>> I'll try to optimize pgv_to_page() after this patch series merged. I
>> am planning to call vmalloc_to_page() previously, and cache its resu=
lt
>> in a per pgv array for future use. Thanks.
>>
>>
>
> Hmm... fact is flush_dcache_page() is void on some arches.
>
> Maybe the only thing to do is avoid pgv_to_page() calls if
> ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE is 0
>

Even then, tpacket_fill_skb() is called for every skb, and
pgv_to_page() is used in it. We have to optimize pgv_to_page().
Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
