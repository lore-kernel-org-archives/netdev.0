From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Fri, 24 Sep 2010 09:01:00 +0200
Message-ID: <1285311660.2380.62.camel@edumazet-laptop>
References: <20100924063623.GA6359@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47365 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564Ab0IXHBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 03:01:06 -0400
Received: by wwd20 with SMTP id 20so73011wwd.1
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 00:01:04 -0700 (PDT)
In-Reply-To: <20100924063623.GA6359@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 06:36 +0000, Jarek Poplawski a =C3=
=A9crit :
> On 2010-09-23 12:15, Changli Gao wrote:
> > Since skb->destructor() is used to account socket memory, and maybe=
 called
> > before the skb is sent out, a corrupt skb maybe sent out finally.
> >=20
> > A new destructor is added into structure skb_shared_info(), and it =
won't
> > be called until the last reference to the data of an skb is put. af=
_packet
> > uses this destructor instead.
>=20
> IMHO, we shouldn't allow for fixing the bad design of one protocol at
> the expense of others by adding more and more conditionals. The prope=
r
> way of handling paged skbs (splice compatible) exists. And the curren=
t
> patch doesn't even fix the problem completely against things like
> pskb_expand_head or pskb_copy.
>=20
> af_packet could check some flag which guarantees the queued dev can d=
o
> skb_orphan after the real xmit and copy buffers otherwise.

Agreed.

af_packet (tx with mmap) is broken. I wonder who really uses it ?

To properly cope with paged skbs, it should not try to fit several
packets per page.

The mmap api should change so that one mmaped page belongs to at most
one skb, or else we need invasive changes in net/core

This probably makes this stuff less interesting, unless the need is to
send big packets. In this case, why splice was not used instead of
custom mmap ?


