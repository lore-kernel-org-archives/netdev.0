From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 net-next 3/4] secure_seq: use SipHash in place of MD5
Date: Sun, 8 Jan 2017 13:23:52 +0100
Message-ID: <CAHmME9rJQTD8taAvcL8+ffsz1nQTLy9z8+1AzV_WVTGgwwQWZA@mail.gmail.com>
References: <20170107144057.15432-1-Jason@zx2c4.com> <20170107144057.15432-4-Jason@zx2c4.com>
 <20170107.163736.2224609477435674963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Biggers <ebiggers3@gmail.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andi Kleen <ak@linux.intel.com>,
        David Laight <David.Laight@aculab.com>,
        Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:35597 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933111AbdAHMX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 07:23:58 -0500
In-Reply-To: <20170107.163736.2224609477435674963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sat, Jan 7, 2017 at 10:37 PM, David Miller <davem@davemloft.net> wrote:
> This and the next patch are a real shame, performance wise, on cpus
> that have single-instruction SHA1 and MD5 implementations.  Sparc64
> has both, and I believe x86_64 can do SHA1 these days.
>
> It took so long to get those instructions into real silicon, and then
> have software implemented to make use of them as well.

Actually, from a performance perspective, these patches are strictly
better than what was already there, since nothing actually used the
special instructions. They're also better security wise, because the
prior use of these functions was quite dubious. On x86, using the FPU
isn't really an option in these situations, as you well know. On
Sparc64, sure, I guess it's a bummer that silicon is lagging
cryptography. If after merging these improvements, you want to start
thinking about a special construction just for Sparc64 that would be
faster and have a matching security level, this would of course be
great. But so far, nobody even bothered to do this for the old
insecure slow code that this is replacing.

> Who knows when we'll see SipHash widely deployed in any instruction
> set, if at all, right?  And by that time we'll possibly find out that
> "Oh shit, this SipHash thing has flaws!" and we'll need
> DIPPY_DO_DA_HASH and thus be forced back to a software implementation
> again.

The literature and cryptanalyses on SipHash have been quite positive.
And as I mentioned earlier in patchset messages, SipHash is really
_not_ some newfangled hipster thing, but rather something that's been
around a while, pretty extensively studied, and considered quite
venerable. I think if you're going to bet on something SipHash is one
of the more safe bets to be made.

> I understand the reasons why these patches are being proposed, I just
> thought I'd mention the issue of cpus that implement secure hash
> algorithm instructions.

Yea, agreed, it's a bummer. Hopefully silicon will catch up someday,
and we'll all be happy. In the meantime, at least these patches
improve the situation on Linux.

I interpret your letter's omission of any substantive comments on the
code itself to be an indication that things are mostly sane. I'll
follow up with Eric's suggestions to produce a v3, and then hopefully
we can get this merged.

Regards,
Jason
