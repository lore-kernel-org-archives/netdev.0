From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] ipv6: no CHECKSUM_PARTIAL on skbs with extension
 headers and recalc checksum during fragmentation
Date: Mon, 26 Oct 2015 10:19:23 -0400
Message-ID: <CALx6S34WNYxQ4HOG0hg-jO_U-OYhGABS8xaqTD1v4Q0fx-6QtQ@mail.gmail.com>
References: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
	<CALx6S35of-Qpo5c+AW5h6_CXbTiZG0yn5_J0skK_LZ4UMxikiA@mail.gmail.com>
	<1445704123.1816692.419166185.45622C02@webmail.messagingengine.com>
	<CALx6S35ttmhwMzbPRCkSApbgvJXcgC-kAzuiDQvOc=98mBQEnQ@mail.gmail.com>
	<1445706124.1823412.419177649.420E8888@webmail.messagingengine.com>
	<CALx6S37krurU1nFpC-9aT_EDhZfH7p=-wSrSjUSNKvm5+s_c2Q@mail.gmail.com>
	<1445852946.87102.420207505.5C1EF1DC@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:32768 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbbJZOTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 10:19:24 -0400
Received: by igbkq10 with SMTP id kq10so73796397igb.0
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 07:19:23 -0700 (PDT)
In-Reply-To: <1445852946.87102.420207505.5C1EF1DC@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We already concluded that drivers do have this problem and not the stack
> above ip6_fragment. The places I am aware of I fixed in this patch. Also
> IPv4 to me seems unaffected, albeit one can certainly clean up the logic
> in net-next.
>
I don't understand why checksum for IP fragments is a driver problem.
When fragments are sent to driver they should never have
CHECKSUM_PARTIAL set (or maybe that is what you are seeing?).

> Do you want to move the skb_checksum_help() check to the front of
> ip_fragment in ipv4 now too?
>
Yes, it seems to me we should never fragment a packets with
CHECKSUM_PARTIAL. This seems to currently be possible in IP output (v4
& v6). I would imagine that we don't see this bug trip (too often?)
because most uses of UDP got through the user space fragmentation
code, and UDP packets sent through kernel path probably don't have a
frag_list so they go through slow path.

Also, as Eric suggested, it looks like your patch is doing two things
(fixing csum/fragmentation and disabling csum_partial for any
extension headers)-- these should be separate patches.

Thanks,
Tom

> My patch fixed the part above ip6_fragment (in ip6_append_data) and made
> sure we don't send out packets with wrong checksums if we get to
> ip6_fragment directly.
>
> Bye,
> Hannes
