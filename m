From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v3 1/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Wed, 25 Jan 2012 13:09:13 +0000
Message-ID: <1327496953.24561.323.camel@zakaz.uk.xensource.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
	 <1327494434-21566-1-git-send-email-ian.campbell@citrix.com>
	 <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:63591 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab2AYNJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 08:09:15 -0500
In-Reply-To: <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-01-25 at 12:51 +0000, Eric Dumazet wrote:
> Le mercredi 25 janvier 2012 =C3=A0 12:27 +0000, Ian Campbell a =C3=A9=
crit :
> > This reduces the minimum overhead required for this allocation such=
 that the
> > shinfo can be grown in the following patch without overflowing 2048=
 bytes for a
> > 1500 byte frame.
> >=20
> > Reducing this overhead while also growing the shinfo means that som=
etimes the
> > tail end of the data can end up in the same cache line as the begin=
ning of the
> > shinfo. Specifically in the case of the 64 byte cache lines on a 64=
 bit system
> > the first 8 bytes of shinfo can overlap the tail cacheline of the d=
ata. In many
> > cases the allocation slop means that there is no overlap.
> >=20
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
>=20
> Hmm... you missed build_skb()

Presumably build_skb should be using SKB_WITH_OVERHEAD instead of open
coding it? (which I think is how I managed to miss it)

>  and all places we use
> SKB_DATA_ALIGN(sizeof(struct skb_shared_info))

> (for example in some drivers)

I'm not sure how I missed these with my grep. Obviously it is necessary
to catch them all in order to avoid the performance drop you mention
below. Fortunately there is fewer than a dozen instances in half a doze=
n
drivers to check.

> If you want to see possible performance impact of your changes, see
> commit e52fcb2462ac (bnx2x: uses build_skb() in receive path), and
> expect a drop from 820.000 pps to 720.000 pps

Can you elaborate on the specific benchmark you used there?

Thanks,
Ian
