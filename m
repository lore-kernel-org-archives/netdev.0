From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Mon, 21 Apr 2008 18:17:00 +0200
Message-ID: <200804211817.01189.tomasz@grobelny.oswiecenia.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <480C7E50.3050508@trash.net> <20080421131253.GB12221@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4912 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112AbYDUQR0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 12:17:26 -0400
In-Reply-To: <20080421131253.GB12221@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Monday 21 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82:
> Em Mon, Apr 21, 2008 at 01:45:20PM +0200, Patrick McHardy escreveu:
> > Tomasz Grobelny wrote:
> >> 2. If the sole purpose of this change was to keep skb->cb zeroed t=
hen it
> >> doesn't seem to me like the right solution. Wasting about 20 bytes
> >> instead of zeroing them when needed I would consider at least weir=
d. I
> >> understand that TCP and UDP may have enough space left but it just
> >> turned out that DCCP doesn't.
> >
> > It was the safest solution that late in a release. It also
> > avoids to memset the cb unnecessarily. If the room is not
> > enough anymore, its easy to go back to using memset.
>
> Nod, if we don't need the space reserved for the lower layer protocol=
s
> in DCCP it is actually the best solution, as we don't need to zero th=
e
> cb again before passing it to IP, it gets zeroed at alloc_skb time an=
d
> that is it. If we need the space, we have to pay the price of
> memset before passing to IP.
>
Ok, so in this case the patch for DCCP could be reverted in test tree, =
is that=20
right? Were these two deleted memsets zeroing all that was necessary or=
 were=20
there any other bugs fixed by the patch?
If we iron this out we could finally return to the main subject of this=
=20
thread. That is Patch v2 by me and Gerrit...
--=20
Regards,
Tomasz Grobelny
