From: David Miller <davem@davemloft.net>
Subject: Re: Netlink mmap tx security?
Date: Tue, 14 Oct 2014 22:09:08 -0400 (EDT)
Message-ID: <20141014.220908.123550384430402000.davem@davemloft.net>
References: <CALCETrWDSG2EhxBnM8Jm55Ov8PYQ_w3Wf88SKYOB1q1WgRpbEw@mail.gmail.com>
	<20141014.220111.179628329028952302.davem@davemloft.net>
	<CALCETrW1HFJ3QXMfV9Hv922eax0hbHJn5GmHPvtED8_JR5KOVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org, tgraf@suug.ch
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926AbaJOCJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 22:09:10 -0400
In-Reply-To: <CALCETrW1HFJ3QXMfV9Hv922eax0hbHJn5GmHPvtED8_JR5KOVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 14 Oct 2014 19:03:11 -0700

> On Tue, Oct 14, 2014 at 7:01 PM, David Miller <davem@davemloft.net> wrote:
>> I really think this means I'll have to remove all of the netlink
>> mmap() support in order to prevent from breaking applications. :(
>>
>> The other option is to keep NETLINK_TX_RING, but copy the data into
>> a kernel side buffer before acting upon it.
> 
> Option 3, which sucks but maybe not that badly: change the value of
> NETLINK_RX_RING.  (Practically: add NETLINK_RX_RING2 or something like
> that.)

That would work as well.

There are pros and cons to all of these approaches.

I was thinking that if we do the "TX mmap --> copy to kernel buffer"
approach, then if in the future we find a way to make it work
reliably, we can avoid the copy.  And frankly performance wise it's no
worse than what happens via normal sendmsg() calls.

And all applications using NETLINK_RX_RING keep working and keep
getting the performance boost.
