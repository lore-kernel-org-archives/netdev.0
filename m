From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] l2tp: fix oops in l2tp_eth_create() error path
Date: Fri, 02 Nov 2012 21:57:05 -0400 (EDT)
Message-ID: <20121102.215705.177696570905508047.davem@davemloft.net>
References: <1351590108-21067-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482Ab2KCB5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:57:07 -0400
In-Reply-To: <1351590108-21067-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Tue, 30 Oct 2012 09:41:48 +0000

> When creating an L2TPv3 Ethernet session, if register_netdev() should fail for
> any reason (for example, automatic naming for "l2tpeth%d" interfaces hits the
> 32k-interface limit), the netdev is freed in the error path.  However, the
> l2tp_eth_sess structure's dev pointer is left uncleared, and this results in
> l2tp_eth_delete() then attempting to unregister the same netdev later in the
> session teardown.  This results in an oops.
> 
> To avoid this, clear the session dev pointer in the error path.
> 
> Signed-off-by: Tom Parkin <tparkin@katalix.com>

Applied, thanks.
