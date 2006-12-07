From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: change spinlocks and remove timers in favor of workqueues
Date: Thu, 07 Dec 2006 12:22:01 -0800
Message-ID: <200612072022.kB7KM1gv012011@death.nxdomain.ibm.com>
References: <20061130162322.GA8772@gospo.rdu.redhat.com> <200611301938.kAUJchgv020451@death.nxdomain.ibm.com> <bdfc5d6e0611301215o3e3e0c73wb22156b57ba7ed0f@mail.gmail.com> <200612050049.kB50nwgv023439@death.nxdomain.ibm.com> <bdfc5d6e0612061801wc276619l3c4b6d498ca4e8fd@mail.gmail.com> <200612070646.kB76kbgv004791@death.nxdomain.ibm.com> <bdfc5d6e0612070525u320b0b65j161819b730e3b9ac@mail.gmail.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:60530 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1163278AbWLGUWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 15:22:16 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB7KM71r026592
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 15:22:07 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB7KM3rU539786
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 13:22:06 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB7KM3G7027971
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 13:22:03 -0700
To: "Andy Gospodarek" <andy@greyhouse.net>
In-reply-to: <bdfc5d6e0612070525u320b0b65j161819b730e3b9ac@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:
[...]
>My patch actually only uses a single workqueue for each bond (almost
>exactly like yours in-fact) with 4 different types of work that can be
>placed on it.

	Well, what I was trying to say was that there are still multiple
independently scheduled thingies on the workqueue (although you can't
ever have all of them going at the same time), whereas in the Big Patch,
there's only one scheduled thingie on the workqueue, and everything is
dispatched from within its single handler (making it less complicated to
pause all of the "timers" for mutual exclusion purposes).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
