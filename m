From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix kfree(skb)
Date: Tue, 27 Feb 2007 10:00:52 -0800 (PST)
Message-ID: <20070227.100052.59655152.davem@davemloft.net>
References: <45E46518.5070100@trash.net>
	<200702271235.22671.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org, acme@ghostprotocols.net
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44696
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751728AbXB0SBS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 13:01:18 -0500
In-Reply-To: <200702271235.22671.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Paul Moore <paul.moore@hp.com>
Date: Tue, 27 Feb 2007 12:35:22 -0500

> On Tuesday, February 27 2007 12:06:32 pm Patrick McHardy wrote:
> > diff --git a/net/netlabel/netlabel_unlabeled.c
> > b/net/netlabel/netlabel_unlabeled.c index 5bc3718..b931ede 100644
> > --- a/net/netlabel/netlabel_unlabeled.c
> > +++ b/net/netlabel/netlabel_unlabeled.c
> > @@ -173,7 +173,7 @@ static int netlbl_unlabel_list(struct sk
> > =A0=A0=A0=A0=A0=A0=A0=A0return 0;
> > =A0
> > =A0list_failure:
> > -=A0=A0=A0=A0=A0=A0=A0kfree(ans_skb);
> > +=A0=A0=A0=A0=A0=A0=A0kfree_skb(ans_skb);
> > =A0=A0=A0=A0=A0=A0=A0=A0return ret_val;
> > =A0}
>=20
> Acked-by: Paul Moore <paul.moore@hp.com>
>=20
> Thanks for catching this, it looks like I used kfree_skb() elsewhere =
but for=20
> some reason missed it here.

It's unfortunately an easy mistake to make since kfree() accepts any
pointer type without warning.

What would be really nice is if someone could come up with a way for
kfree() to disallow being passed objects that are meant to be released
via some other mechanism.  So that, for example:

	kfree(skb);

would warn or fail to compile, but the kfree_skb() code could go:

	kmem_cache_free_I_KNOW_WHAT_I_AM_DOING(skbuff_head_cache, skb);

:-)
