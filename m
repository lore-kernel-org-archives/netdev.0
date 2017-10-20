From: Joshua Kinard <kumba@gentoo.org>
Subject: Re: [PATCH] net/ethernet/sgi: Code cleanup
Date: Thu, 19 Oct 2017 22:00:46 -0400
Message-ID: <a7a9232d-e53e-91b9-7cb8-6eccecb8af01@gentoo.org>
References: <53f0ad54-514a-b572-5801-7bd237055f86@gentoo.org>
 <20171019.132704.299365871401082792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
        netdev@vger.kernel.org, tglx@linutronix.de,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019.132704.299365871401082792.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2017 08:27, David Miller wrote:
> From: Joshua Kinard <kumba@gentoo.org>
> Date: Tue, 17 Oct 2017 13:54:30 -0400
> 
>> From: Joshua Kinard <kumba@gentoo.org>
>>
>> The below patch attempts to clean up the code for the in-tree driver
>> for IOC3 ethernet and serial console support, primarily used by SGI
>> MIPS platforms.  Notable changes include:
>>
>>   - Lots of whitespace cleanup
>>   - Using shorthand integer types (u16, u32, etc) where appropriate
> 
> These seem to be arbitrary, "unsigned int" is a fine value for a
> hash computation.

I can back those changes out if you'd like.  I was aiming more for consistency.
 There is one specific change that is required, where the IP protocol number is
being parsed into a signed char field when it should be unsigned char.  I can
send that in as its own patch if you'd like.


> You're also making many different kinds of changes in one patch
> which makes it very difficult to review.

This patch is more of a preparation patch, because I have additional pending
changes to move towards using the IOC3 "metadriver" (drivers/sn/ioc3.c) on the
supported MIPS/SGI systems.  That metadriver is only used by IA64 right now.
The changes in this patch were primarily to reduce the diff size of the
metadriver patch when I get time to get it cleaned up.

I can either try for a v2 of this patch to split it up, or hold off and make it
part of the metadriver patch.  I figured since that patch will need to go
through several subsystem reviewers, better to try sending this one in first.


> This driver is also for such ancient hardware, that the risk
> of potentially breaking the driver far outweighs the value of
> "cleaning up" the code.

I am familiar with this hardware, actually.  I have several SGI machines
powered on periodically that use this particular chip, and am familiar with its
quirks and frustrations.  Although it's been a while since I tested this
specific batch of changes by itself, the last time I did, the machine booted
fine.  With the metadriver patch applied on top, I know this driver works
well-enough.

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
6144R/F5C6C943 2015-04-27
177C 1972 1FB8 F254 BAD0 3E72 5C63 F4E3 F5C6 C943

"The past tempts us, the present confuses us, the future frightens us.  And our
lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic
