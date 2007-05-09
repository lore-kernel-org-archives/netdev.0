From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Wed, 9 May 2007 12:53:05 +0530
Message-ID: <OF6A57F86D.C63329E8-ON652572D6.0027B2E9-652572D6.00289106@in.ibm.com>
References: <20070508.233630.35664266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:58420 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966432AbXEIHYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 03:24:03 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l497hbTG189062
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 17:43:38 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l497RQen130536
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 17:27:27 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l497Nsd2005556
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 17:23:54 +1000
In-Reply-To: <20070508.233630.35664266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote on 05/09/2007 12:06:30 PM:

> But this only makes sense for the second hunk you changed.

I think it should work fine for both.

> The first hunk is a bug case, an improper looping device
> decapsulation condition, and we do want to always return
> -1 in that case in order to break out of the loop.

I guess you meant "we do *not* want to always return -1" ?

> Your change will make the kernel essentially hang instead
> when this bug check is triggered.

By returning -1, we end up freeing all the skbs one by one, or
until the condition : "transient error caused by hard_start_xmit
recursing" is over. Essentially, that behavior is also not
changed in my patch (only run time change is to return 0 if
there are no more skbs).

Thanks,

- KK

