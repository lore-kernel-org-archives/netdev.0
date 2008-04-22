From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Tue, 22 Apr 2008 22:45:53 +0200
Message-ID: <200804222245.53322.tomasz@grobelny.oswiecenia.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804211817.01189.tomasz@grobelny.oswiecenia.net> <480D6FFA.80205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:3039 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755789AbYDVUqK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 16:46:10 -0400
In-Reply-To: <480D6FFA.80205@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Tuesday 22 of April 2008, napisa=C5=82e=C5=9B:
> Tomasz Grobelny wrote:
> > Dnia Monday 21 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82=
:
> >> Nod, if we don't need the space reserved for the lower layer proto=
cols
> >> in DCCP it is actually the best solution, as we don't need to zero=
 the
> >> cb again before passing it to IP, it gets zeroed at alloc_skb time=
 and
> >> that is it. If we need the space, we have to pay the price of
> >> memset before passing to IP.
> >
> > Ok, so in this case the patch for DCCP could be reverted in test tr=
ee, is
> > that right? Were these two deleted memsets zeroing all that was nec=
essary
> > or were there any other bugs fixed by the patch?
>
> No, those two memsets became unnecessary by the addition
> of the new cb members. If you want to remove them again,
> you need to add those memsets back and additionally add
> memsets that zero the first sizeof(inet_skb_parm)/
> sizeof(inet6_skb_parm) bytes everywhere else where packets
> are passed to IP(v6).
Maybe I wasn't clear enough with my question. I understand that these t=
wo=20
memsets would have to be readded. But my question is: did you identify =
any=20
bugs that were caused by junk in skb->cb before applying your patch? If=
 so,=20
do you have any test cases? It could help to check code for correctness=
 if=20
one day more space in skb->cb will be needed (which of course doesn't h=
ave to=20
be in the nearest future).
--=20
Regards,
Tomasz Grobelny
