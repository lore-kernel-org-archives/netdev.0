From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: no CHECKSUM_PARTIAL on skbs with extension headers
 and recalc checksum during fragmentation
Date: Mon, 26 Oct 2015 10:49:06 +0100
Message-ID: <1445852946.87102.420207505.5C1EF1DC@webmail.messagingengine.com>
References: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
 <CALx6S35of-Qpo5c+AW5h6_CXbTiZG0yn5_J0skK_LZ4UMxikiA@mail.gmail.com>
 <1445704123.1816692.419166185.45622C02@webmail.messagingengine.com>
 <CALx6S35ttmhwMzbPRCkSApbgvJXcgC-kAzuiDQvOc=98mBQEnQ@mail.gmail.com>
 <1445706124.1823412.419177649.420E8888@webmail.messagingengine.com>
 <CALx6S37krurU1nFpC-9aT_EDhZfH7p=-wSrSjUSNKvm5+s_c2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46293 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753726AbbJZJtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 05:49:09 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 27473207C8
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 05:49:07 -0400 (EDT)
In-Reply-To: <CALx6S37krurU1nFpC-9aT_EDhZfH7p=-wSrSjUSNKvm5+s_c2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 25, 2015, at 14:32, Tom Herbert wrote:
> > Anyway, currently it is easy to generate broken checksums on the wire
> > and would like to solve that for net, we certainly can improve that in
> > net-next.
> >
> Hannes,
> 
> The IPv4 fragment code is very similar to IPv6 in that both will
> perform skb_checksum_help only in the slow_path, so it seems like
> skb_checksum_help should be called earlier before the fragments are
> generated in both cases. If we're not correctly setting checksum for
> packets that are fragmented that is an issue with the stack.

We already concluded that drivers do have this problem and not the stack
above ip6_fragment. The places I am aware of I fixed in this patch. Also
IPv4 to me seems unaffected, albeit one can certainly clean up the logic
in net-next.

Do you want to move the skb_checksum_help() check to the front of
ip_fragment in ipv4 now too?

My patch fixed the part above ip6_fragment (in ip6_append_data) and made
sure we don't send out packets with wrong checksums if we get to
ip6_fragment directly.

Bye,
Hannes
