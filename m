From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/12] bna: TX Path and RX Path Changes
Date: Mon, 22 Aug 2011 16:45:41 -0700 (PDT)
Message-ID: <20110822.164541.1084485895386350206.davem@davemloft.net>
References: <1314052869-7407-1-git-send-email-rmody@brocade.com>
	<1314052869-7407-5-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	gkaraje@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183Ab1HVXqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 19:46:44 -0400
In-Reply-To: <1314052869-7407-5-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Mon, 22 Aug 2011 15:41:01 -0700

> +		if (unlikely(skb_is_gso(skb) > netdev->mtu)) {

skb_is_gso() is mean to be a boolean test, it happens to return
the value of ->gso_size as it's implementation but that's not
a good reason for you to abuse this interface in this way.

If we every fix skb_is_gso() to return a true 'bool' your driver
will break.

Access ->gso_size directly if that's what you're interested in,
that way it's future proof and won't break in the future.

