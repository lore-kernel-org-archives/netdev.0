From: David Miller <davem@davemloft.net>
Subject: Re: ipv6_mc_check_mld - kernel BUG at net/core/skbuff.c:1128
Date: Tue, 11 Aug 2015 21:56:11 -0700 (PDT)
Message-ID: <20150811.215611.1190651644766573423.davem@davemloft.net>
References: <CAMUH3-WBobHryNpxYUzuAr4bPBFkd=QFkWgOoLyGiVf6Qvx0Ww@mail.gmail.com>
	<20150811205140.GD4402@odroid>
	<20150811214725.GE4402@odroid>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bblanco@plumgrid.com, netdev@vger.kernel.org
To: linus.luessing@c0d3.blue
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714AbbHLE4O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 00:56:14 -0400
In-Reply-To: <20150811214725.GE4402@odroid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Tue, 11 Aug 2015 23:47:25 +0200

> On Tue, Aug 11, 2015 at 10:51:40PM +0200, Linus L=FCssing wrote:
>> On Mon, Aug 10, 2015 at 02:56:12PM -0700, Brenden Blanco wrote:
>> > Doing some code reading with Alexei, we found a suspect commit, wh=
ich
>> > introduces an skb_get and skb_may_pull of the same skb, which lead=
s to the BUG
>> > when skb->len =3D=3D len.
>>=20
>> Urgh, didn't know that pskb_may_pull() doesn't like an skb with a
>> reference count greater than one... But yes, the BUG() call in
>> skbuff.c:1128 / pskb_expand_head() says that (though in this case
>> the BUG() in skbuff.c call actually seems kinda weird (/"wrong"?), a=
s
>> it isn't shared between different code paths).
>=20
> The more I think about it, I'm tending to remove the BUG() call in
> pskb_expand_head() as in this case it obviously isn't a bug.

Calling pskb_expand_head() with a shared SKB is absolutely,
positively, a bug.  You just don't understand why it is.
