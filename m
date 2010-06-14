From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 18:15:28 +0800
Message-ID: <AANLkTinFc9HqkyWa9Q6k9hzEeDkjjwIyKeztvzHRx-BU@mail.gmail.com>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
	<1276493743.2448.41.camel@edumazet-laptop> <AANLkTimN1-uyAvpxgpno55XoyPzBptdZimz-MA-0MCWZ@mail.gmail.com>
	<1276499096.2478.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36926 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755469Ab0FNKPu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 06:15:50 -0400
Received: by vws14 with SMTP id 14so468879vws.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 03:15:48 -0700 (PDT)
In-Reply-To: <1276499096.2478.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 14, 2010 at 3:04 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
>
> Concept of 'fast path' has changed over years. It used to be cpu
> instructions and cycles, its now number of memory transactions.
>
> The only thing we need to address are the cache lines we must bring i=
nto
> cpu caches, and keep code short.
>
> These days, one cache line miss -> more than one hundred instructions
> that could be done during cpu stall. cpu cycles are cheap if code
> already in instruction cache.
>
> Adding a test to avoid entering a NULL loop (no fragment is stored ye=
t)
> just bloats the code, making it larger than necessary.
>
> You dont need the else branch :
>
> if (prev) {
> =A0 =A0 =A0 =A0if (FRAG_CB(prev)->offset < offset) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto found;
> =A0 =A0 =A0 =A0}
> else {
> =A0 =A0 =A0 =A0next =3D NULL;
> =A0 =A0 =A0 =A0goto found;
> }
>
> Just write :
>
> next =3D NULL;
> if (prev && FRAG_CB(prev)->offset < offset)
> =A0 =A0 =A0 =A0goto found;
>

Thanks:

I think the following code is better:

if (!prev || FRAG_CB(prev)->offset < offset) {
      next =3D NULL;
      goto found;
}


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
