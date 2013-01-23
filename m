From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 20:46:29 -0500 (EST)
Message-ID: <20130122.204629.607263597214211092.davem@davemloft.net>
References: <1358894653.12374.201.camel@edumazet-glaptop>
	<20130122.194143.1205292712415183747.davem@davemloft.net>
	<1358903293.12374.492.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490Ab3AWBqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 20:46:36 -0500
In-Reply-To: <1358903293.12374.492.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Jan 2013 17:08:13 -0800

> On Tue, 2013-01-22 at 19:41 -0500, David Miller wrote:
> 
>> We don't emit crap onto the wire knowingly.  Jesse is right.
>> 
>> If you want to do software GSO in situations where we know that the
>> paged data cannot be modified asynchronously, you'll have to
>> explicitly support that.
>> 
>> I will not accept us saying that allowing the emission of bad
>> checksums is OK.  It never is.  That's terrible behavior, and creates
>> impossible to disagnose problems.
> 
> How is this related to GRE only ?
> 
> We have dozen of skb_checksum_help() calls that basically have the same
> issue.
> 
> Am I missing some obvious thing ?

Then all of them need fixing.

We can't emit bogus checksums on the wire when this is completely
under our control.
