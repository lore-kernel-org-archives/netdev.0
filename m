From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] ipv6: no CHECKSUM_PARTIAL on skbs with extension
 headers and recalc checksum during fragmentation
Date: Sun, 25 Oct 2015 09:32:58 -0400
Message-ID: <CALx6S37krurU1nFpC-9aT_EDhZfH7p=-wSrSjUSNKvm5+s_c2Q@mail.gmail.com>
References: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
	<CALx6S35of-Qpo5c+AW5h6_CXbTiZG0yn5_J0skK_LZ4UMxikiA@mail.gmail.com>
	<1445704123.1816692.419166185.45622C02@webmail.messagingengine.com>
	<CALx6S35ttmhwMzbPRCkSApbgvJXcgC-kAzuiDQvOc=98mBQEnQ@mail.gmail.com>
	<1445706124.1823412.419177649.420E8888@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35308 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbbJYNc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 09:32:59 -0400
Received: by igbkq10 with SMTP id kq10so42964078igb.0
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 06:32:59 -0700 (PDT)
In-Reply-To: <1445706124.1823412.419177649.420E8888@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Anyway, currently it is easy to generate broken checksums on the wire
> and would like to solve that for net, we certainly can improve that in
> net-next.
>
Hannes,

The IPv4 fragment code is very similar to IPv6 in that both will
perform skb_checksum_help only in the slow_path, so it seems like
skb_checksum_help should be called earlier before the fragments are
generated in both cases. If we're not correctly setting checksum for
packets that are fragmented that is an issue with the stack.

Tom

> Bye,
> Hannes
