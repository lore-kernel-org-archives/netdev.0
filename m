From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 20 Sep 2010 09:14:26 +0000
Message-ID: <20100920091425.GA8381@ff.dom.local>
References: <1283852248.2338.160.camel@edumazet-laptop> <20100910.125449.235704956.davem@davemloft.net> <20100911123140.GA1939@del.dom.local> <20100919.171725.245378386.davem@davemloft.net> <20100920072149.GA6353@ff.dom.local> <1284973320.3420.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58697 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab0ITJOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 05:14:30 -0400
Received: by bwz11 with SMTP id 11so4086633bwz.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 02:14:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1284973320.3420.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 20, 2010 at 11:02:00AM +0200, Eric Dumazet wrote:
> Le lundi 20 septembre 2010 ?? 07:21 +0000, Jarek Poplawski a =E9crit =
:
>=20
> > Probably we could start from enhacing moving drivers to paged skbs
> > where possible. And maybe simplifying the skb model by not allowing
> > frags and frag lists together?
> >=20
>=20
> Sure. I believe current model, pre-allocating skb in huge tx rings is=
 a
> waste of mem bandwidth anyway. (I am refering to the struct sk_buff
> itself, not the payload part)
>=20
> Of course some drivers are doing it right, using netdev_alloc_skb()
> right before feeding this skb to network stack, not an old one.
>=20
> > Btw, I wonder what is the exact reason we can't use only
> > NET_SKBUFF_DATA_USES_OFFSET?
>=20
> I see no real reason.
>=20
> On 32bit arches, it might be faster to manipulate pointers, and not
> 'base+offset' values.

The only reason is code readability and maintenance. Did anybody check
how much faster?

Jarek P.
