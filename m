From: Rob Landley <rlandley@parallels.com>
Subject: Re: 2.6.38 containers bug: Infinite loop in /proc/sys/net/ipv6/neigh/neigh/neigh...
Date: Wed, 30 Mar 2011 06:27:48 -0500
Message-ID: <4D9313B4.2070104@parallels.com>
References: <4D9302F3.6080206@parallels.com>	<20110330.033529.71582712.davem@davemloft.net>	<4D9309B4.2000501@parallels.com> <20110330.034820.124005354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	<containers@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<stable@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110330.034820.124005354.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/30/2011 05:48 AM, David Miller wrote:
> From: Rob Landley <rlandley@parallels.com>
> Date: Wed, 30 Mar 2011 05:45:08 -0500
> 
>> So you think letting it soak in the merge window and the churn of -rc1
>> (which currently doesn't boot for me due to an ide issue) will provide
>> more validity than a specific "There was an infinite loop in the
>> filesystem, there is now no longer an infinite loop in the filesystem,
>> here's the specific test for it" and visual inspection ofthe patch?
> 
> Yes I absolutely do think it's better to let it soak somewhere than
> to repeat the reason why this patch is necessary in the first place.
> 
> This patch is necessary because Eric already screwed up trying to fix
> this neigh dirctory under ipv6 once, and he got it wrong.
> 
> That patch looked correct and straightforward.
> 
> Yet it introduced the bug you're seeing.
> 
> Given that consideration, are you still holding steady to your
> opinion wise guy? :-)

The patch fixed the specific bug I hit (find /proc hanging), and didn't
noticeably make the system worse in my use cases.  I have a specific
test case which used to fail and now succeeds.  The system _without_ the
patch is broken, and I weigh the possibility of breakage with the patch
against that. I wasn't particularly concerned with it being the "right"
fix from a long-term structural standpoint because that's what 2.6.39 is
for.  I just wanted the obvious breakage (a regression from 2.6.37) to
go away, I tested this fix and it Worked For Me (tm), hence letting the
stable guys know about it being the obvious next move.

How many people do you think are likely to even try containers under
2.6.39-rc1 or -rc2?  Eric's patch introducing the bug is dated January
31, and it was in 2.6.38-rc4.  Apparently nobody noticed the breakage in
-rc5, -rc6, -rc7, or -rc8.  His patch fixing the bug is dated one week
after 2.6.38 shipped.  I also noticed it in the stable kernel, not in
any of the 2.6.38-rc releases.  So at least two people hit this in
-stable already, and nobody hit it in -dev for four -rc releases.  I
have tested it in 2.6.38 and it Worked For Me.  Supposing the new patch
did introduce subtle breakage, how is leaving it in the 2.6.39-dev
series for a _month_ more likely to find it than the entire second half
of the 2.6.38 development cycle (when it was at its most stable, and
thus easiest to test)?

I have no idea if this patch fixes 2.6.39-rc1, because -rc1 still
doesn't _boot_ in my test environment.  Many other things about -rc1 are
broken.  That's sort of the point of -rc1.  A fairly small number of
people test the development branch, and this is the most unstable time
of the development cycle where many things about it are _expected_ not
to work.  Especially right now, I don't see how letting it "soak" for a
week or two in the -dev branch accomplishes anything whatsoever.

So yes, I am still holding steady to my opinion.  But you're the
maintainer, so my opinion doesn't really matter here.

Rob
