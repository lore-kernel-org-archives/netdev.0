From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/6] Convert bonding timers to workqueues
Date: Mon, 15 Oct 2007 12:08:59 -0700
Message-ID: <20038.1192475339@death>
References: <11920760494096-git-send-email-fubar@us.ibm.com> <11920760502756-git-send-email-fubar@us.ibm.com> <4713B44E.7030902@pobox.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:45075 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756230AbXJOTJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 15:09:08 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9FJ96T5026837
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 15:09:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9FJ96lV091202
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 15:09:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9FJ9588013593
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 15:09:05 -0400
In-reply-to: <4713B44E.7030902@pobox.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:

>Jay Vosburgh wrote:
>> 	Convert bonding timers to workqueues.  This converts the various
>> monitor functions to run in periodic work queues instead of timers.  This
>> patch introduces the framework and convers the calls, but does not resolve
>> various locking issues, and does not stand alone.
>>
>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>
>"does not stand alone" == it is not bisectable?  That's a problem.

	The patch will compile fine (this is true for any point in the
series), but it's possible for bonding to deadlock or misbehave when
doing certain operations.  Those problems are addressed in the later
patches.

	I didn't want to just vomit out one big mega-patch that has the
whole set of changes, because that's harder to understand, and the later
patches generally address discrete issues.

	Does that make you more or less nervous about its bisectability?
I can repost the whole thing as a big blob if that's what you'd prefer.

>Anyway, we have more fun fish to fry:  after applying the IPoIB bonding
>patchset, this no longer applies...

	Yah, I'll rebase it (once I know your blob vs. not-blob
preference).  I wasn't sure how long the IPoIB mystery bug hunt was
going to take.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
