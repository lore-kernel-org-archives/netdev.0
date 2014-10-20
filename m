From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sun, 19 Oct 2014 17:32:15 -0700
Message-ID: <CA+55aFz4UdVbZKPKwkesj0=1Yu7jLDP3Q3-jwe45b7gRU+0rog@mail.gmail.com>
References: <20141019.132314.264021750039480460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:46018 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbaJTAcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 20:32:16 -0400
In-Reply-To: <20141019.132314.264021750039480460.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 19, 2014 at 10:23 AM, David Miller <davem@davemloft.net> wrote:
>
> A quick batch of bug fixes:

Ho humm.. Here's another networking issue with the current kernel:

  nf_reject_ipv6: module license 'unspecified' taints kernel.
  Disabling lock debugging due to kernel taint
  nf_reject_ipv6: Unknown symbol ip6_local_out (err 0)

Hmm? I'm not sure this is new, but I hadn't noticed it before. The
"unknown symbol" seems to be simply because ip6_local_out is GPL-only,
and without a proper license, 'nf_reject_ipv6' not only taints the
kernel but doesn't link properly..

Looks like the module license issue was just overlooked when moving
the code out in commit c8d7b98bec43 ("netfilter: move nf_send_resetX()
code to nf_reject_ipvX modules").

                     Linus
