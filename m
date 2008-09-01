From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] *icsk_ca_priv: Reduce inet_connection_sock size?
Date: Sun, 31 Aug 2008 21:03:31 -0700 (PDT)
Message-ID: <20080831.210331.252498451.davem@davemloft.net>
References: <48BAE26A.4060002@danielinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, angelo.tornese@gmail.com
To: root@danielinux.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750748AbYIAEDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 00:03:37 -0400
In-Reply-To: <48BAE26A.4060002@danielinux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Lacamera <root@danielinux.net>
Date: Sun, 31 Aug 2008 20:26:50 +0200

> This simple patch (2.6.26) replaces the icsk_ca_priv big array with a
> void pointer, reducing the default inet_connection_sock size by 60Bytes.
> 
> Each "congestion controlled" socket must allocate and free its own priv
> structure if needed, from the connection init and release callbacks
> inside each module.
> 
> Wouldn't this reduce memory usage for sockets that don't use ca?

Yes, but for every TCP socket there is a new memory allocation and
free.

We're trying to decrease the number of those rather than increase them
because having more of them non-trivially impacts TCP connection
rates.
