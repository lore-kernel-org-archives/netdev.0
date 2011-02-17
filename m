From: Cypher Wu <cypher.w@gmail.com>
Subject: Re: Fwd: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Thu, 17 Feb 2011 14:42:35 +0800
Message-ID: <AANLkTi=Z6=5v3vKwu1HZsB1CBQ_acdmjbVG4PZbfM_OC@mail.gmail.com>
References: <AANLkTimj+_8cBz0gcEyF1889xK2HdF4SQDSK8DiY-4Gs@mail.gmail.com>
	<20110217044917.GA2653@cr0.nay.redhat.com>
	<AANLkTikkro-_9pv5uJ4+SqYh9Fr480_96Wh1Pv6Pvtez@mail.gmail.com>
	<20110217054237.GB2653@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42009 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab1BQGmh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 01:42:37 -0500
In-Reply-To: <20110217054237.GB2653@cr0.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 17, 2011 at 1:42 PM, Am=E9rico Wang <xiyou.wangcong@gmail.c=
om> wrote:
> On Thu, Feb 17, 2011 at 01:04:14PM +0800, Cypher Wu wrote:
>>>
>>> Have you turned CONFIG_LOCKDEP on?
>>>
>>> I think Eric already converted that rwlock into RCU lock, thus
>>> this problem should disappear. Could you try a new kernel?
>>>
>>> Thanks.
>>>
>>
>>I haven't turned CONFIG_LOCKDEP on for test since I didn't get too
>>much information when we tried to figured out the former deadlock.
>>
>>IGMP used read_lock() instead of read_lock_bh() since usually
>>read_lock() can be called recursively, and today I've read the
>>implementation of MIPS, it's should also works fine in that situation=
=2E
>>The implementation of TILEPro cause problem since after it use TNS se=
t
>>the lock-val to 1 and hold the original value and before it re-set
>>lock-val a new value, it a race condition window.
>>
>
> I see no reason why you can't call read_lock_bh() recursively,
> read_lock_bh() is roughly equalent to local_bh_disable() + read_lock(=
),
> both can be recursive.
>
> But I may miss something here. :-/
>

Of course read_lock_bh() can be called recursively, but read_lock() is
already enough for IGMP, the only reason for that deadlock is because
using TNS instruction set the value to 1 cause another race condition.

--=20
Cyberman Wu
