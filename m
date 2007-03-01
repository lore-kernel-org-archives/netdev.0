From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: make IGMP flooding on active-backup bonds configurable
Date: Wed, 28 Feb 2007 17:08:59 -0800
Message-ID: <200703010108.l2118x22001354@death.nxdomain.ibm.com>
References: <20070228222331.GA28813@gospo.rdu.redhat.com> <200702282239.l1SMdg22017137@death.nxdomain.ibm.com> <20070301005934.GA1916@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:60673 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932883AbXCABJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 20:09:02 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l21191xK030518
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 20:09:01 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l21191Q9191182
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 18:09:01 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l21191uh026734
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 18:09:01 -0700
In-reply-to: <20070301005934.GA1916@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Wed, Feb 28, 2007 at 02:39:42PM -0800, Jay Vosburgh wrote:
[...]
>> 	Why would you want to turn this off?
>
>When you connect active-backup bonds to 2 separate switches that are in
>'distant' parts of the network you can end up with a bunch of unwanted
>multicast data flowing everywhere and if you don't care whether or not
>your multicast traffic is highly available then it just seems like
>noise.  I thought the flexibility seemed nice.

	Ok, I can buy the "multicast spew" argument.

>> 	Also, I've got a replacement patch for this functionality that
>> seems to be better in all regards. It sends bonus IGMP joins when a
>> failover occurs, rather than simply duplicating them on all slaves (the
>> current system can leave switches in the dark if the slaves fail back to
>> the originals).  As chance would have it, I'm planning to post it as
>> part of a set in a a little while.
>> 
>
>That sounds like a nice add-on to the existing functionality.  I can see
>the value in something dynamic like that, but I can also see the value
>in something static like the functionality we have.  Did you plan to
>keep the existing functionality intact or just have it done dynamically?

	Well, I posted the patch just a bit ago, so you can see for
yourself, but no, it removes the existing "copy IGMP everywhere"
behavior.  I couldn't really think of an advantage to flooding
everywhere all the time if the hose is re-aimed during failover (if
you'll pardon my cheesy metaphor).

>Is this separate from your workqueue/refactoring patch or does it work
>on the existing code?

	This is separate, for the current mainline.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
