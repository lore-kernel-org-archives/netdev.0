From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] xen-netback: add control protocol
 implementation
Date: Sat, 07 May 2016 15:09:21 -0400 (EDT)
Message-ID: <20160507.150921.2053537729453518863.davem@davemloft.net>
References: <1462447170-1815-1-git-send-email-paul.durrant@citrix.com>
	<1462447170-1815-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbcEGTJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 15:09:23 -0400
In-Reply-To: <1462447170-1815-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Thu, 5 May 2016 12:19:28 +0100

> +struct xenvif_hash_cache {
> +	rwlock_t lock;

You really don't want to lock on every SKB hash computation like
this, turn this into a spin lock for locking the write side and
use RCU locking for lookup and usage.

THanks.
