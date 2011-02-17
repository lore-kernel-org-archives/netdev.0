From: David Miller <davem@davemloft.net>
Subject: Re: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Wed, 16 Feb 2011 21:46:25 -0800 (PST)
Message-ID: <20110216.214625.189707123.davem@davemloft.net>
References: <20110217044917.GA2653@cr0.nay.redhat.com>
	<AANLkTikkro-_9pv5uJ4+SqYh9Fr480_96Wh1Pv6Pvtez@mail.gmail.com>
	<20110217054237.GB2653@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cypher.w@gmail.com, linux-kernel@vger.kernel.org,
	cmetcalf@tilera.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751049Ab1BQFpt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 00:45:49 -0500
In-Reply-To: <20110217054237.GB2653@cr0.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Am=E9rico Wang <xiyou.wangcong@gmail.com>
Date: Thu, 17 Feb 2011 13:42:37 +0800

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
>=20
> I see no reason why you can't call read_lock_bh() recursively,
> read_lock_bh() is roughly equalent to local_bh_disable() + read_lock(=
),
> both can be recursive.
>=20
> But I may miss something here. :-/

IGMP is doing this so that taking the read lock does not stop packet
processing.

TILEPro's rwlock implementation is simply buggy and needs to be fixed.
