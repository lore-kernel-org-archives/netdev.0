From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/14] netvm: Set PF_MEMALLOC as appropriate during SKB
 processing
Date: Thu, 9 Jun 2011 12:35:05 +0100
Message-ID: <20110609113505.GR5247@suse.de>
References: <1307606573-24704-1-git-send-email-mgorman@suse.de>
 <1307606573-24704-11-git-send-email-mgorman@suse.de>
 <BANLkTimUE9yb-DegdUk0BbbOGWoUhEBrqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Micha? Miros?aw <mirqus@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <BANLkTimUE9yb-DegdUk0BbbOGWoUhEBrqw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 09, 2011 at 12:21:31PM +0200, Micha? Miros?aw wrote:
> 2011/6/9 Mel Gorman <mgorman@suse.de>:
> [...]
> > +/*
> > + * Limit which protocols can use the PFMEMALLOC reserves to those th=
at are
> > + * expected to be used for communication with swap.
> > + */
> > +static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
> > +{
> > + =A0 =A0 =A0 switch (skb->protocol) {
> > + =A0 =A0 =A0 case __constant_htons(ETH_P_ARP):
> > + =A0 =A0 =A0 case __constant_htons(ETH_P_IP):
> > + =A0 =A0 =A0 case __constant_htons(ETH_P_IPV6):
> > + =A0 =A0 =A0 case __constant_htons(ETH_P_8021Q):
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> > + =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> > + =A0 =A0 =A0 }
> > +}
>=20
> This is not needed and wrong. Whatever list there will be, it's going
> to always miss some obscure setup (or not that obscure, like
> ATAoverEthernet).
>=20

NBD is updated in the series to set the socket information
appropriately but the same cannot be said of AoE. The necessary
changes have been made IPv4 and IPv6 to handle pfmemalloc sockets
but the same cannot be necessarily said for the other protocols. Yes,
the check could be removed but leaving it there makes a clear statement
on what scenario can be reasonably expected to work.

--=20
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
