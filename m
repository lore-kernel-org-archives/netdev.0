From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: no CHECKSUM_PARTIAL on skbs with extension headers
 and recalc checksum during fragmentation
Date: Sat, 24 Oct 2015 18:28:43 +0200
Message-ID: <1445704123.1816692.419166185.45622C02@webmail.messagingengine.com>
References: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
 <CALx6S35of-Qpo5c+AW5h6_CXbTiZG0yn5_J0skK_LZ4UMxikiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:34319 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752417AbbJXQ2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 12:28:47 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 5D3BA202ED
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 12:28:44 -0400 (EDT)
In-Reply-To: <CALx6S35of-Qpo5c+AW5h6_CXbTiZG0yn5_J0skK_LZ4UMxikiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Sat, Oct 24, 2015, at 18:21, Tom Herbert wrote:
> On Fri, Oct 23, 2015 at 9:13 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > CHECKSUM_PARTIAL should only be used on plain vanilla IPv6 + UDP packets
> > in ip6_append_data. Some drivers don't correctly handle extension headers,
> > especially not ipv6 fragmentation which could result in broken checksums.
> >
> Yes, we've seen this in some drivers, but the conclusion is that those
> drivers are *broken* and need to be fixed! CHECKSUM_PARTIAL works
> perfectly well in the presence of extension headers if the
> driver/device is correctly implemented (simple algorithm with
> csum_start and csum_offset).

I will do some more research on those drivers and I agree in general
with you. But if you look at the code it was clearly the intention to
not use CHECKSUM_PARTIAL on fragmented IPv6 packets, just this intention
has not been formulated correctly in code. I still would like to see
something like that showing up in stable and we can follow more CSUM
bits maybe for drivers who support or don't support that.

Also as we are talking about fragments here, I would not put too much
effort into that, as fragments will be slow path anyway.

Bye,
Hannes
