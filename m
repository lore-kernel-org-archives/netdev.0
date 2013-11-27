From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH] net: smc91: fix crash regression on the versatile
Date: Wed, 27 Nov 2013 13:28:17 +0100
Message-ID: <CACRpkdYBMx=xyWjf13n7o34yqCwVCtdGy=qzt1ZS6M5RvKgmQg@mail.gmail.com>
References: <1385553099-13874-1-git-send-email-linus.walleij@linaro.org>
	<20131127121303.GM16735@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Miao <eric.y.miao@gmail.com>,
	Jonathan Cameron <jic23@cam.ac.uk>,
	stable <stable@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131127121303.GM16735@n2100.arm.linux.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 27, 2013 at 1:13 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Nov 27, 2013 at 12:51:39PM +0100, Linus Walleij wrote:
>> This is because the macro operations in smc91x.h are missing
>> necessary #defines for operations such as SMC_inbsw(),
>> SMC_outsw() and SMC_outsb() making these defined to BUG().
>>
>> The Versatile needs and uses the same accessors as the other
>> platforms in the first if(...) clause, just switch it to using
>> that and we have one problem less to worry about.
>>
>> This bug seems to have been around for some quite time, just
>> that few people test the Versatile on real hardware, and it
>> compiles.
>
> That's a misconception.  This bug is caused by:
>
> commit e9e4ea74f06635f2ffc1dffe5ef40c854faa0a90
> Author: Will Deacon <will.deacon@arm.com>
> Date:   Fri Oct 11 14:52:20 2013 +0100
>
>     net: smc91x: dont't use SMC_outw for fixing up halfword-aligned data

Ah, you're right, reverting that makes things work.

This patch should still be a viable solution, I'll fix up the
commit message and repost a v2.

Yours,
Linus Walleij
