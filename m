From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: Drop budget parameter from NAPI polling call
 hierarchy
Date: Sat, 26 Sep 2015 22:36:31 -0700 (PDT)
Message-ID: <20150926.223631.507670918270362716.davem@davemloft.net>
References: <20150922215049.3088.32475.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbbI0Fge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 01:36:34 -0400
In-Reply-To: <20150922215049.3088.32475.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Tue, 22 Sep 2015 14:56:08 -0700

> Rather than carry around a value of budget that is 0 or less we can instead
> just loop through and pass 0 to each napi->poll call.  If any driver
> returns a value for work done that is non-zero then we can report that
> driver and continue rather than allowing a bad actor to make the budget
> value negative and pass that negative value to napi->poll.

Unfortunately we have drivers that won't do any TX work if the budget
is zero.

Using the budget for TX work is unfortunate and not the recommended
way for drivers to do things, but it's not explicitly disallowed
either.

So I'm not applying this because it definitely has the potential
to break something.

Sorry.
