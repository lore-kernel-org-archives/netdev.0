From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] *icsk_ca_priv: Reduce inet_connection_sock size?
Date: Sun, 31 Aug 2008 23:09:17 +0400
Message-ID: <20080831190916.GA15931@2ka.mipt.ru>
References: <48BAE26A.4060002@danielinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, angelo.tornese@gmail.com
To: Daniele Lacamera <root@danielinux.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:54587 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888AbYHaTJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Aug 2008 15:09:44 -0400
Content-Disposition: inline
In-Reply-To: <48BAE26A.4060002@danielinux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sun, Aug 31, 2008 at 08:26:50PM +0200, Daniele Lacamera (root@danielinux.net) wrote:
> This simple patch (2.6.26) replaces the icsk_ca_priv big array with a
> void pointer, reducing the default inet_connection_sock size by 60Bytes.
> 
> Each "congestion controlled" socket must allocate and free its own priv
> structure if needed, from the connection init and release callbacks
> inside each module.
> 
> Wouldn't this reduce memory usage for sockets that don't use ca?

This will also increase number of allocations in the fast path, isn't
it? This overhead is not acceptible.

-- 
	Evgeniy Polyakov
