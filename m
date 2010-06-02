From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 02 Jun 2010 08:20:19 -0400
Message-ID: <1275481219.14363.6.camel@bigi>
References: <1275272665-19047-1-git-send-email-xiaosuo@gmail.com>
	 <1275395667.3587.38.camel@bigi>
	 <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:60986 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932373Ab0FBMVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:21:16 -0400
Received: by gwaa12 with SMTP id a12so4484582gwa.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 05:21:15 -0700 (PDT)
In-Reply-To: <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Changli,

On Wed, 2010-06-02 at 01:47 +0800, Changli Gao wrote:

> 
> I added the following debug code into cls_u32.c
> 
>                 for (i = n->sel.nkeys; i>0; i--, key++) {
> +                       int off;
> +
> +                       off = key->off+(off2&key->offmask) + (ptr - skb->data);
> +                       if (off + 4 > skb->len)
> +                               printk("skb->len: %d, off: %d\n",
> skb->len, off);
> 

Ok, makes more sense. And thanks for taking time to construct a
meaningful example.
It is not a common use - but i agree it is a bug.
I am suprised we never caught this all this years and wondering why this
never crashed in your example?
Can we make the fix very simple please? i.e no copy bits, this is the
fast path.

> It isn't an optimization, but an error exit. :)

What i meant was if you can tell immediately what the maximum offset is
then you dont need to go through for loop making comparison with each
key. You could immediately bailout - which is an optimization ;->

cheers,
jamal

