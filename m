From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: boot test failure (net tree)
Date: Mon, 22 Aug 2011 19:13:48 -0700 (PDT)
Message-ID: <20110822.191348.2099822249437201579.davem@davemloft.net>
References: <20110822113032.15087c2e190e2b0c3ee7dfb8@canb.auug.org.au>
	<20110823114011.a059aea0138b75bfa7eed1ce@canb.auug.org.au>
	<20110823114129.ceb18da164bf7df3c145941b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	mikey@neuling.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org,
	benh@kernel.crashing.org, paulus@samba.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110823114129.ceb18da164bf7df3c145941b@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 23 Aug 2011 11:41:29 +1000

> On Tue, 23 Aug 2011 11:40:11 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>>
>> On Mon, 22 Aug 2011 11:30:32 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>> >
>> > Here's what I am applying as a merge fixup to the net tree today so that
>> > my ppc64_defconfig builds actually build more or less the same set of
>> > drivers as before this rearrangement.
>> 
>> And this today:
> 
> And this:

I'm starting to get uncomfortable with this whole situation, and I
feel more and more that these new kconfig guards are not tenable.

Changing defconfig files might fix the "automated test boot with
defconfig" case but it won't fix the case of someone trying to
automate a build and boot using a different, existing, config file.
It ought to work too, and I do know people really do this.

And just the fact that we would have to merge all of these defconfig changes
through the networking tree is evidence of how it's really not reasonable
to be doing things this way.

Jeff, I think we need to revert the dependencies back to what they were
before the drivers/net moves.  Could you prepare a patch which does that?
