From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH] tilepro ethernet driver: fix a few minor issues
Date: Wed, 4 Apr 2012 08:18:08 -0400
Message-ID: <4F7C3C00.5020105@tilera.com>
References: <201203302325.q2UNPm8j012403@farm-0012.internal.tilera.com> <20120403.182335.782073108961783777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403.182335.782073108961783777.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/3/2012 6:23 PM, David Miller wrote:
> From: Chris Metcalf <cmetcalf@tilera.com>
> Date: Fri, 30 Mar 2012 19:23:35 -0400
>
>> This commit fixes a number of issues seen with the driver:
>>
>> - Improve handling of return credits to the hardware shim
>> - Use skb_frag_size() appropriately
>> - Add netpoll support to run console over UDP
>>
>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> Please do not mix pure bug fixes and new features.

Fair point.  The (trivial) netpoll change went in in response to an
internal bug saying "hey, console over UDP is broken with the tile driver"
so it seemed like a bug. :-)

> Submit the pure bug fixes separately for 'net' tree submission
> and then submit feature additions like netpoll support in
> a patch targetting the 'net-next' tree.

To use management-speak, there seem to be some "dotted-line reporting"
issues for this code.  It didn't occur to me that you would push it through
the net tree; I assumed I would push it through the tile tree.  (In fact,
shortly before I got your email I had asked Linus to pull it.)  I'm happy
to do it either way; would you prefer to take this stuff for the net trees
going forward?

>> +	/* Handle completions if needed to make room. */
>> +	/* NOTE: Return NETDEV_TX_BUSY if there is still no room. */
> Do not format comments like this, use something like this instead:

I will do a follow-up patch to fix up the comment style throughout the
whole driver.

Thanks!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
