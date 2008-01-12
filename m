From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 9/9] fix sparse warnings
Date: Sat, 12 Jan 2008 13:09:46 -0800
Message-ID: <20080112130946.4d83eca7@deepthought>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.659443238@linux-foundation.org>
	<4788A17D.5070903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48853 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758045AbYALVMV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 16:12:21 -0500
In-Reply-To: <4788A17D.5070903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Jan 2008 12:16:13 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > Make FIB TRIE go through sparse checker without warnings.
> >=20
> > Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
>=20
> Hi Stephen
>=20
> While reviewing your patches (and fib code) I had some questions :
>=20
> 1) I was wondering isn't trie_collect_stats() a potential cpu hog
> (big latency) ?
>=20
> 2) struct tnode layout
>     If tnode->bits is large enough, we allocate a big area
>     of memory but roughly use only first half of it.
>     We could use a better scheme with an extra indirection. For small
>     nodes, we use space right after tnode, but for big nodes, we allo=
cate
>     a power of two set of pages, to exactly match the memory need.
>=20
> 3) 'pos' and 'bits' fields of 'struct tnode' might be converted to
>     plain uchar, instead of 5-bits fields, to reduce complexity for
>     generated code.
>=20
> 4) full_children & empty_children being 'unsigned short',
>     we probably are limited to 2^15 elements, but I could not
>     find this limit enforced somewhere.
>=20
> [FIB]: Reduce text size of net/ipv4/fib_trie.o
>=20
> In struct tnode, we use two fields of 5 bits for 'pos' and 'bits'.
> Switching to plain 'unsigned char' (8 bits) take the same space
> because of compiler alignments, and reduce text size by 435 bytes
> on i386.
>=20
> On i386 :
> $ size net/ipv4/fib_trie.o.before_patch net/ipv4/fib_trie.o
>     text    data     bss     dec     hex filename
>    13714       4      64   13782    35d6 net/ipv4/fib_trie.o.before
>    13279       4      64   13347    3423 net/ipv4/fib_trie.o
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20

I agree they should not have been bitfields in the first place.

--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>
