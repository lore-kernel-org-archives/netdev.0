From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Fix race between access of desc and desc
 index
Date: Tue, 27 Oct 2015 19:50:07 -0700 (PDT)
Message-ID: <20151027.195007.1435133435434786670.davem@davemloft.net>
References: <20151026221354.927.9237.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940AbbJ1Cd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:33:26 -0400
In-Reply-To: <20151026221354.927.9237.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Mon, 26 Oct 2015 17:13:54 -0500

> During Tx cleanup it's still possible for the descriptor data to be
> read ahead of the descriptor index. A memory barrier is required between
> the read of the descriptor index and the start of the Tx cleanup loop.
> This allows a change to a lighter-weight barrier in the Tx transmit
> routine just before updating the current descriptor index.
> 
> Since the memory barrier does result in extra overhead on arm64, keep
> the previous change to not chase the current descriptor value. This
> prevents the execution of the barrier for each loop performed.
> 
> Suggested-by: Alexander Duyck <alexander.duyck@gmail.com>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks.
