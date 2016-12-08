From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pch_gbe: Fix TX RX descriptor accesses for big
 endian systems
Date: Thu, 08 Dec 2016 13:29:30 -0500 (EST)
Message-ID: <20161208.132930.657087361052763772.davem@davemloft.net>
References: <1481133534-26224-1-git-send-email-hassan.naveed@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.burton@imgtec.com,
        matt.redfearn@imgtec.com, fw@strlen.de, romieu@fr.zoreil.com
To: hassan.naveed@imgtec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752419AbcLHS3c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:29:32 -0500
In-Reply-To: <1481133534-26224-1-git-send-email-hassan.naveed@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hassan Naveed <hassan.naveed@imgtec.com>
Date: Wed, 7 Dec 2016 09:58:54 -0800

> Fix pch_gbe driver for ethernet operations for a big endian CPU.
> Values written to and read from transmit and receive descriptors
> in the pch_gbe driver are byte swapped from the perspective of a
> big endian CPU, since the ethernet controller always operates in
> little endian mode. Rectify this by appropriately byte swapping
> these descriptor field values in the driver software.
> 
> Signed-off-by: Hassan Naveed <hassan.naveed@imgtec.com>
> Reviewed-by: Paul Burton <paul.burton@imgtec.com>
> Reviewed-by: Matt Redfearn <matt.redfearn@imgtec.com>

As explained by Francois, you need to use the proper endian types in
the descriptor datastructure.

Then please run sparse with endianness checking enabled on the build
of the driver.
