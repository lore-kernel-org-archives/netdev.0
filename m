From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Sun, 12 Apr 2009 21:27:37 +0200
Message-ID: <7e0dd21a0904121227n3b03f2c7v8bf30c45667603a1@mail.gmail.com>
References: <1239108520.32737.28.camel@dogo.mojatatu.com>
	 <1239112067.32737.51.camel@dogo.mojatatu.com>
	 <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com>
	 <1239137800.21227.10.camel@dogo.mojatatu.com>
	 <20090407211130.GA5918@ioremap.net>
	 <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com>
	 <7e0dd21a0904120327q537956abkf75a17d477cc2e61@mail.gmail.com>
	 <20090412103212.GA28397@ioremap.net>
	 <7e0dd21a0904120423v4296898fl7ce82ec8c3e42d3a@mail.gmail.com>
	 <20090412142451.GA2694@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:45793 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbZDLT1k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2009 15:27:40 -0400
Received: by bwz17 with SMTP id 17so1785036bwz.37
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2009 12:27:37 -0700 (PDT)
In-Reply-To: <20090412142451.GA2694@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've seen that during skb_linearize(), skb_shinfo(skb)->frags[i].page
is not lost even if pages has been put. So I can get back original
frag address from this info in skb destructor. Can I rely on
skb_shinfo(skb)->frags[i].page on more complicated sending paths ... ?

Thanks in advance,
Johann





On Sun, Apr 12, 2009 at 4:24 PM, Evgeniy Polyakov <zbr@ioremap.net> wro=
te:
> On Sun, Apr 12, 2009 at 01:23:30PM +0200, Johann Baudy (johann.baudy@=
gnu-log.net) wrote:
>> > Page itself will live until destruction time, when skb is lineariz=
ed
>> > page is freed, so your own destructor will find that given page is=
 no
>> > longer used, and appropriate memory area can be overwritten.
>> Ok, so if my understanding is correct, fragment data is copied, frag=
s
>> info (page, offset, size ...) of =A0skb_shinfo(skb) remain available=
 and
>> skb->data_len is equal to 0 (to tag it as linear).
>> Then I can use address of skb_shinfo(n)->frags[0].page to derive my
>> header whatever sending path.
>
> No, I was wrong, linearization may silently put pages without calling=
 a
> destructor.
>
> --
> =A0 =A0 =A0 =A0Evgeniy Polyakov
>



--=20
Johann Baudy
johaahn@gmail.com
