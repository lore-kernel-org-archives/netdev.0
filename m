From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Wed, 19 Nov 2014 15:31:36 -0500 (EST)
Message-ID: <20141119.153136.867017618826698045.davem@davemloft.net>
References: <20141118084745.GT7996@ZenIV.linux.org.uk>
	<CA+55aFxK0wj2LLp0WmhRsBZch8XfoYbzmbEeJaMpt=SDh5GBvw@mail.gmail.com>
	<20141118212307.GU7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756542AbaKSUbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 15:31:38 -0500
In-Reply-To: <20141118212307.GU7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Tue, 18 Nov 2014 21:23:07 +0000

> On Tue, Nov 18, 2014 at 12:49:13PM -0800, Linus Torvalds wrote:
>> "access_ok()" isn't that expensive, and removing them as unnecessary
>> is fraught with errors. We've had several cases of "oops, we used
>> __get_user() in a loop, because it generates much better code, but
>> we'd forgotten to do access_ok(), so now people can read kernel data".
> 
> OK...  If netdev folks can live with that for now, I've no problem with
> dropping 3/5.  However, I really think we need a variant of csum-and-copy
> that would _not_ bother with access_ok() longer term.  That can wait, though...

I think because of the way Al verifies things at the top level, and
how we structure access to these msg->msg_iov so strictly, these cases
of access_ok() really can safely go.

But that is just my opinion, and yes I do acknowledge that we've had
serious holes in this area in the past.
