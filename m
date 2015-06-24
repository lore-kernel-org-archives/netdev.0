From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 24 Jun 2015 16:38:11 -0700
Message-ID: <CA+55aFybr6Fjti5WSm=FQpfwdwgH1Pcfg6L81M-Hd9MzuSHktg@mail.gmail.com>
References: <20150624.063911.1220157256743743341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34139 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbbFXXiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 19:38:12 -0400
In-Reply-To: <20150624.063911.1220157256743743341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2015 at 6:39 AM, David Miller <davem@davemloft.net> wrote:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master

Just going through the conflicts, I see commit 7193a141eb74 ("IB/mlx4:
Set VF to read from QP counters"), and wonder...

Is that code really supposed to fall through to the
infiniband-over-ethernet case when the link layer is
IB_LINK_LAYER_INFINIBAND but it's a slave?

The commit message is not in the least helpful.

On the *other* side of the same conflict, I find an even more
offensive commit, namely commit 4cd7c9479aff ("IB/mad: Add support for
additional MAD info to/from drivers") which adds a BUG_ON() for a
sanity check, rather than just returning -EINVAL or something sane
like that.

I'm getting *real* tired of that BUG_ON() shit. I realize that
infiniband is a niche market, and those "commercial grade" niche
markets are more-than-used-to crap code and horrible hacks, but this
is still the kernel. We don't add random machine-killing debug checks
when it is *so* simple to just do

        if (WARN_ON_ONCE(..))
                return -EINVAL;

instead.

Killing the machine for idiotic things like that is truly offensive,
and truly horrible horrible code. Why do I keep on having to tell
people off for doing these things? Why do people keep thinking that
debugging-by-killing-the-machine is a good idea?

Either that BUG_ON() cannot possibly happen, in which case it should
damn well not exist in the first place. Or it's a valuable debug aid,
in which case it should damn well not be a BUG_ON. You can't have it
both ways.

The next pointless BUG_ON() I see, I will start getting _really_
unpleasant about.

Doug, get rid of those things asap.

                    Linus
