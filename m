From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] netpoll: Drop budget parameter from NAPI
 polling call hierarchy
Date: Tue, 29 Sep 2015 14:57:32 -0700 (PDT)
Message-ID: <20150929.145732.752475022422386278.davem@davemloft.net>
References: <20150928161426.1098.72362.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbbI2V5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 17:57:32 -0400
In-Reply-To: <20150928161426.1098.72362.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Mon, 28 Sep 2015 09:16:17 -0700

> For some reason we were carrying the budget value around between the
> various calls to napi->poll.  If for example one of the drivers called had
> a bug in which it returned a non-zero value for work this could result in
> the budget value becoming negative.
> 
> Rather than carry around a value of budget that is 0 or less we can instead
> just loop through and pass 0 to each napi->poll call.  If any driver
> returns a value for work done that is non-zero then we can report that
> driver and continue rather than allowing a bad actor to make the budget
> value negative and pass that negative value to napi->poll.
> 
> Note, the only actual change here is that instead of letting budget become
> negative we are keeping it at 0 regardless of the value returned for work
> since it should not be possible for the polling routine to do any actual
> work with a budget of 0.  So if the polling routine returns a non-0 value
> we are just reporting it and continuing with a budget of 0 rather than
> letting that work value be subtracted from the budget of 0.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied, thanks.
