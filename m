From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dcbnl : Disable software interrupts before taking
 dcb_lock
Date: Sun, 16 Nov 2014 14:51:26 -0500 (EST)
Message-ID: <20141116.145126.191966834846491028.davem@davemloft.net>
References: <1416011911-28998-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
	neerav.parikh@intel.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38023 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaKPTv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 14:51:29 -0500
In-Reply-To: <1416011911-28998-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Fri, 14 Nov 2014 16:38:31 -0800

> Solves possible lockup issues that can be seen from firmware DCB agents calling
> into the DCB app api.
> 
> DCB firmware event queues can be tied in with NAPI so that dcb events are
> generated in softIRQ context. This can results in calls to dcb_*app()
> functions which try to take the dcb_lock.
> 
> If the the event triggers while we also have the dcb_lock because lldpad or
> some other agent happened to be issuing a  get/set command we could see a cpu
> lockup.
> 
> This code was not originally written with firmware agents in mind, hence
> grabbing dcb_lock from softIRQ context was not considered.
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.
