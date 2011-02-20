From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Sun, 20 Feb 2011 08:33:02 -0500
Message-ID: <4D61180E.4090608@tilera.com>
References: <4D5DA60A.8080201@tilera.com>	<20110217.145333.232751283.davem@davemloft.net>	<4D5DA96D.5060200@tilera.com>	<20110217.151147.35033921.davem@davemloft.net>	<4D5DACC5.60105@tilera.com>	<AANLkTim1F679mmnbHnYkvi6ZDojxD-tPGer4F+61C+di@mail.gmail.com>	<4D5EE9E9.2000407@tilera.com> <AANLkTi=uQTQjrXn4_w-YwKCutpENFdFrxQed5kVKXTDF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <xiyou.wangcong@gmail.com>,
	<linux-kernel@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=uQTQjrXn4_w-YwKCutpENFdFrxQed5kVKXTDF@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/18/2011 11:07 PM, Cypher Wu wrote:
> On Sat, Feb 19, 2011 at 5:51 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
>> I heard from one of our support folks that you were asking through that
>> channel, so I asked him to go ahead and give you the spinlock sources
>> directly.  I will be spending time next week syncing up our internal tree
>> with the public git repository so you'll see it on LKML at that time.
> I've got your source code, thank you very much.
>
> There is still two more question:
> 1. Why we merge the inlined code and the *_slow into none inlined functions?

Those functions were always borderline in terms of being sensible inlined
functions.  In my opinion, adding the SPR writes as well pushed them over
the edge, so I made them just straight function calls instead, for code
density reasons.  It also makes the code simpler, which is a plus.  And
since I was changing the read_lock versions I changed the write_lock
versions as well for consistency.

> 2. I've seen the use of 'mb()' in unlock operation, but we don't use
> that in the lock operation.

You don't need a memory barrier when acquiring a lock.  (Well, some
architectures require a read barrier, but Tile doesn't speculate loads past
control dependencies at the moment.)

> I've released a temporary version with that modification under our
> customer' demand, since they want to do a long time test though this
> weekend. I'll appreciate that if you gave some comment on my
> modifications:

It seems OK functionally, and has the advantage of addressing the deadlock
without changing the module API, so it's appropriate if you're trying to
maintain binary compatibility.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
