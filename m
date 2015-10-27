From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 1/4] ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked
 sockets
Date: Tue, 27 Oct 2015 17:34:04 +0100
Message-ID: <1445963644.1412577.421660985.2D10CC9A@webmail.messagingengine.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
 <1445958135-19805-2-git-send-email-hannes@stressinduktion.org>
 <CALx6S36PRh1EmmydMAUhZVxyyAanNYBTRUzTN67=dHnbBTNOGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:33658 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932394AbbJ0QeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 12:34:06 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 1CDFE20965
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 12:34:05 -0400 (EDT)
In-Reply-To: <CALx6S36PRh1EmmydMAUhZVxyyAanNYBTRUzTN67=dHnbBTNOGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015, at 17:04, Tom Herbert wrote:
> On Tue, Oct 27, 2015 at 8:02 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > We cannot reliable calculate packet size on MSG_MORE corked sockets
> > and thus cannot decide if they are going to be fragmented later on,
> > so better not use CHECKSUM_PARTIAL in the first place.
> >
> MSG_MORE should be independent of checksum offload. If packet is
> fragmented the fix in ip_output will ensure that skb_checksum_help is
> properly called.

The probability is that we are going to fragment if MSG_MORE is set,
because exceeding link mtu is quite probable, see e.g. NFS use case. Why
not simply use the csum functions during copy-in in that case? It makes
much more sense to me.

I don't see a reason to test for fragment length at all, then.

Bye,
Hannes
