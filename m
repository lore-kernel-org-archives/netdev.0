From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() -> cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 08:12:53 -0800
Message-ID: <11218.1261066373@death.nxdomain.ibm.com>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com> <20091217074930.GA6779@ff.dom.local> <20091217133644.GD8654@ff.dom.local> <1261060259.10356.112.camel@johannes.local>
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Mikhail Markine <markine@google.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:40644 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759356AbZLQQNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 11:13:15 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBHG4AVS006026
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 11:04:10 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHGD9BG126586
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 11:13:09 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHGD7Wa021660
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 09:13:08 -0700
In-reply-to: <1261060259.10356.112.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> wrote:

>On Thu, 2009-12-17 at 13:36 +0000, Jarek Poplawski wrote:
>> On Thu, Dec 17, 2009 at 02:19:46PM +0100, Johannes Berg wrote:
>> > Jarek,
>> > 
>> > Sorry to mail you directly, but I only saw your reply on gmane and
>> > didn't want to break up the threading etc.
>> > 
>> > cancel_delayed_work_sync() should be ok in this case unless the work
>> > items themselves used the rtnl,
>> 
>> Hmm, I'm not sure I get your point, but e.g. bond_mii_monitor() work
>> function can get rtnl_lock().
>
>Ok in that case you can't cancel_sync() it under rtnl. I was thinking of
>the case where it's just not ok because of other work. Sorry for the
>confusion!

	There's already logic in the monitors (bond_mii_monitor, et al)
to check a sentinel (kill_timers) and do nothing (not acquire rtnl) and
return.

	What exactly is the nature of the race that doing cancel..sync
is fixing?  The bond_close function sets kill_timers prior to calling
the cancel functions, so the monitor function might run once, but it
should do nothing.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
