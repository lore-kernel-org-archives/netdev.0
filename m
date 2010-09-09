From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Wed, 08 Sep 2010 21:30:59 -0700 (PDT)
Message-ID: <20100908.213059.98904271.davem@davemloft.net>
References: <1283986576.2428.21.camel@edumazet-laptop>
	<AANLkTimZ=i1=c3SaEsw2_ncWJenuOgoSmHpMuN_UiG4K@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50725
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003Ab0IIEal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 00:30:41 -0400
In-Reply-To: <AANLkTimZ=i1=c3SaEsw2_ncWJenuOgoSmHpMuN_UiG4K@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Wed, 8 Sep 2010 16:49:27 -0700

> On Wed, Sep 8, 2010 at 3:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Use cmpxchg() to get rid of spinlocks in inet_add_protocol() and
>> friends.
>>
>> inet_protos[] & inet6_protos[] are moved to read_mostly section
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> What's the benefit to this?  It's hard to imagine that add/deleting
> protocols is highly contended.  On the other hand, a simple spinlock
> is very easy to look at and verify correct, while this takes a little
> more thought.

Smaller data section is the benefit, thus less cache pressure there.

It's not about contention at all.

We've already applied other similar changes from Eric doing exactly
this kind of transformation and it's not all that non-trivial to me,
frankly.
