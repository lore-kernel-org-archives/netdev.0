From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Help: major pppoe regression since 2.6.35 (panic on first ppp
 conection)?
Date: Thu, 23 Dec 2010 13:12:28 +0100
Message-ID: <1293106348.7789.5.camel@edumazet-laptop>
References: <20101222110021.GA8985@ff.dom.local>
	 <4D122093.6060900@scarlet.be> <1293035100.3027.247.camel@edumazet-laptop>
	 <4D132C5F.8090404@scarlet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Joel Soete <soete.joel@scarlet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56806 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab0LWMMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 07:12:35 -0500
In-Reply-To: <4D132C5F.8090404@scarlet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 d=C3=A9cembre 2010 =C3=A0 11:02 +0000, Joel Soete a =C3=A9c=
rit :
> Hello Eric,
>=20
>=20
> On 12/22/2010 04:25 PM, Eric Dumazet wrote:
> [snip]
> >
> > Something overwrites nr_frags in skb_shinfo(skb)
> >
> > As skb_shinfo follows head portion of an skb, something overflows s=
kb
> > head
> >
> > Please try adding some room like in following patch ?
> >
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index e6ba898..adf2834 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -187,6 +187,7 @@ enum {
> >    * the end of the header data, ie. at skb->end.
> >    */
> >   struct skb_shared_info {
> > +	char		filler[64];
> >   	unsigned short	nr_frags;
> >   	unsigned short	gso_size;
> >   	/* Warning: this field is not always filled in (UFO)! */
> >
> Sorry for delay but I have good news, I am sending this answer from:
> $ uname -a
> Linux sidh2 2.6.37-rc7-amd64-t1 #1 SMP Thu Dec 23 10:30:27 GMT 2010 x=
86_64 GNU/Linux
>=20
> with your tips ;<) (without kernel had already died)
>=20
> That said how can find stuff overflowing skb head? (all I say, is tha=
t this issue started with 2.6.34-git6???)
>=20
> Thanks a lot,

You're welcome. At least we know were to search. Thanks !

I am taking holidays right now for about 5 days, I guess someone else
might find the bug before me ;)



