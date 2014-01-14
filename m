From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 net-next 2/5] {IPv4,xfrm} Add ESN support for AH
 ingress part
Date: Tue, 14 Jan 2014 11:09:00 +0100
Message-ID: <20140114100900.GI31491@secunet.com>
References: <1389663552-29638-1-git-send-email-fan.du@windriver.com>
 <1389663552-29638-3-git-send-email-fan.du@windriver.com>
 <20140114095425.GH31491@secunet.com>
 <52D50AFC.6030302@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36004 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbaANKJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 05:09:02 -0500
Content-Disposition: inline
In-Reply-To: <52D50AFC.6030302@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 06:01:32PM +0800, Fan Du wrote:
>=20
>=20
> On 2014=E5=B9=B401=E6=9C=8814=E6=97=A5 17:54, Steffen Klassert wrote:
> >On Tue, Jan 14, 2014 at 09:39:09AM +0800, Fan Du wrote:
> >>@@ -381,7 +393,14 @@ static int ah_input(struct xfrm_state *x, stru=
ct sk_buff *skb)
> >>  	sg_init_table(sg, nfrags);
> >>  	skb_to_sgvec(skb, sg, 0, skb->len);
> >>
> >>-	ahash_request_set_crypt(req, sg, icv, skb->len);
> >>+	if (x->props.flags&  XFRM_STATE_ESN) {
> >>+		sg_unmark_end(&sg[nfrags - 1]);
> >>+		/* Attach seqhi sg right after packet payload */
> >>+		*seqhi =3D htonl(XFRM_SKB_CB(skb)->seq.output.hi);
> >
> >This is ah_input(), so you should use the high bits of the input
> >sequence number here. The ipv6 patch has the same problem.
>=20
> ok, I will fix this.
>=20
> >
> >>+		sg_init_table(seqhisg, sglists);
> >
> >Why do you add a separate SG table for this?
>=20
> It just initialize a single seqhisg, which is actually followed behin=
d packet payload sg table.
> initialized seqhisg actually mark itself as the end of sg list.
>=20

Why don't you just add this entry to the existing SG table?
