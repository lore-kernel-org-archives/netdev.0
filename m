From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netconsole: fix NULL pointer dereference
Date: Thu, 24 Oct 2013 13:56:14 -0400 (EDT)
Message-ID: <20131024.135614.1725589105857635534.davem@davemloft.net>
References: <1382533489-19248-1-git-send-email-nikolay@redhat.com>
	<20131024102147.GD16787@redhat.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73A9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, nikolay@redhat.com, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053Ab3JXR4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 13:56:15 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73A9@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Thu, 24 Oct 2013 11:39:02 +0100

>> >Taking the spinlock seems like the cleanest way to insure there's noone
>> >running in parallel, but I'm open to suggestions as I'm not satisfied with
>> >the looks of this. I'll prepare a net-next patchset for netconsole soon to
>> >clean it up properly, all of these can be easily simplified.
>> 
>> First when I've seen 'spin_lock(); a = 1; spin_unlock()' I've thought
>> "WTF?", however indeed it will stop us racing with write_msg().
> 
> Ditto - might be worth saying:
>     /* Acquire lock to wait for any write_msg() to complete. */

Something this subtle definitely requires a comment.
