From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] batman-adv: fix soft-interface MTU computation
Date: Mon, 17 Feb 2014 16:13:14 -0500 (EST)
Message-ID: <20140217.161314.741869447870850076.davem@davemloft.net>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
	<1392670129-2498-2-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	mareklindner@neomailbox.ch
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaBQVNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:13:20 -0500
In-Reply-To: <1392670129-2498-2-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Mon, 17 Feb 2014 21:48:40 +0100

> +	atomic_set(&bat_priv->packet_size_max, min_mtu);

Please fix this.

The only operations performed on packet_size_max are 'set' and
'read'.  This is not what one uses atomic_t's for.

The use of an atomic_t in this context is a NOP.  You aren't
getting any kind of synchronization at all.
