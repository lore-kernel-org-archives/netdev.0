From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] get_compat_msghdr(): get rid of field-by-field copyin
Date: Thu, 13 Jul 2017 19:36:02 -0700 (PDT)
Message-ID: <20170713.193602.14448503583172802.davem@davemloft.net>
References: <20170708182100.GR10672@ZenIV.linux.org.uk>
        <20170711.202514.815304234636661456.davem@davemloft.net>
        <20170714013750.GC13102@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752825AbdGNCgF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 22:36:05 -0400
In-Reply-To: <20170714013750.GC13102@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 14 Jul 2017 02:37:50 +0100

> On Tue, Jul 11, 2017 at 08:25:14PM -0700, David Miller wrote:
> 
>> looks harmless, or if there is a bug in there I can't see it.
>> 
>> But whatever it is, that same problem could be hiding in some of these
>> other transformations as well.
>> 
>> I think the bug might be that we are corrupting the user's stack
>> somehow.  But the two user copies in that commit look perfectly fine
>> to my eyes.
>> 
>> There shouldn't be any padding in that compat_rlimit structure, so
>> it's not like we're copying extra bytes.  Well, we'd be exposing
>> kernel stack memory if that were the case.
> 
> There isn't any padding in compat_rlimit; unfortunately, it was
> mistakenly declared as struct rlimit instead.  Which, of course,
> has different member sizes - otherwise we wouldn't have needed
> a compat syscall there in the first place.
> 
> It was harder to spot since I combined move and a transformation
> into one commit.  Shouldn't have done so...  Had those been two
> separate commits, the bug would've stood out immediately.  Shouldn't
> be the case here...

Ok, I'll ack these patches then:

Acked-by: David S. Miller <davem@davemloft.net>
