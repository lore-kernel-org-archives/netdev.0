From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: set `error' value not under lock_sock().
Date: Wed, 09 Mar 2016 15:37:15 -0500 (EST)
Message-ID: <20160309.153715.770009288781656553.davem@davemloft.net>
References: <20160309182217.GA9708@jwg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wjeong@barracuda.com, weongyo.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbcCIUhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 15:37:17 -0500
In-Reply-To: <20160309182217.GA9708@jwg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weongyo Jeong <weongyo.linux@gmail.com>
Date: Wed, 9 Mar 2016 10:22:21 -0800

> A trivial patch to set `error' variable while not holding
> lock_sock().
> 
> Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>

Deferring the assignment means gcc doesn't have to potentially put it
on the stack across the lock_sock() call.

You're making the code worse not better, the assignment into a local
variable is not an expensive operation.

I'm not applying this change, sorry.
