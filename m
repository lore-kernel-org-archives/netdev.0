From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rds: Don't allocate rds_sock on stack
Date: Mon, 25 Aug 2014 12:57:40 -0700 (PDT)
Message-ID: <20140825.125740.214306460002405867.davem@davemloft.net>
References: <1408926755-12277-1-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org,
	broonie@linaro.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbaHYT5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 15:57:42 -0400
In-Reply-To: <1408926755-12277-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Sun, 24 Aug 2014 19:32:35 -0500

> From: Mark Brown <broonie@linaro.org>
> 
> struct rds_sock is rather large ausing the following warning in an ARM
> allmodconfig:
> 
> net/rds/iw_rdma.c:200:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> 
> Fix this by dynamically allocating struct rds_sock in rds_iw_update_cm_id
> instead of allocating it on the stack.
> 
> Signed-off-by: Mark Brown <broonie@linaro.org>

I'd like you to fix this differently.  Creating pseudo instances of
objects, and partially initializing it, just to satisfy an interface
is always a really bad sign.

Create a key structure argument for rds_iw_get_device() and initialize that
and pass it in instead, update the other caller similarly.

Thanks.
