From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: compare_ether_addr[_64bits]() has no ordering
Date: Mon, 07 May 2012 19:20:52 -0400 (EDT)
Message-ID: <20120507.192052.181899101154654170.davem@davemloft.net>
References: <1336397946.4325.27.camel@jlt3.sipsolutions.net>
	<1336398809.3752.2313.camel@edumazet-glaptop>
	<1336399961.4325.30.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755219Ab2EGXV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 19:21:58 -0400
In-Reply-To: <1336399961.4325.30.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 07 May 2012 16:12:41 +0200

> On Mon, 2012-05-07 at 15:53 +0200, Eric Dumazet wrote:
>> On Mon, 2012-05-07 at 15:39 +0200, Johannes Berg wrote:
>> > From: Johannes Berg <johannes.berg@intel.com>
>> > 
>> > Neither compare_ether_addr() nor compare_ether_addr_64bits()
>> > (as it can fall back to the former) have comparison semantics
>> > like memcmp() where the sign of the return value indicates sort
>> > order. We had a bug in the wireless code due to a blind memcmp
>> > replacement because of this.
>> > 
>> > A cursory look suggests that the wireless bug was the only one
>> > due to this semantic difference.
>> > 
>> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
>> > ---
>> >  include/linux/etherdevice.h |   11 ++++++-----
>> >  1 file changed, 6 insertions(+), 5 deletions(-)
>> 
>> The right way to avoid this kind of problems is to change these
>> functions to return a bool
> 
> Well, I guess so, but that'd be a weird thing for a compare_ function...
> should probably be named equal_... then, but I'm not really able to do
> such a huge change on the first day after my vacation :-)

It's true the name could be improved, but changing the name is quite
a large undertaking even with automated scripts.

Even the bool change is slightly painful, since all of the explicit
tests against integers (%99.999 of these are in wireless BTW :-) would
need to be adjusted.

For now, I'll just apply Johannes's comment fix.
