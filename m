From: David Miller <davem@davemloft.net>
Subject: Re: Checksum offload queries
Date: Tue, 08 Dec 2015 12:09:11 -0500 (EST)
Message-ID: <20151208.120911.1930136653560954435.davem@davemloft.net>
References: <5665A848.9010001@solarflare.com>
	<CALx6S37+YVqpVL6XX2KCHZad84DGpqpL+K4LdDZr5H-feiyjow@mail.gmail.com>
	<5666FF46.6030702@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393AbbLHRJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:09:12 -0500
In-Reply-To: <5666FF46.6030702@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 8 Dec 2015 16:03:18 +0000

> NETIF_F_HW_CSUM is limited to one checksum per packet.

This is false.

As we demux encapsulation layers, we re-adjust the provided 1's
complement sum provided and use that to validate the next layer.

This works for arbitrarily nested encapsulations, and therefore
can support mutliple checksums per packet.

Tom has also created a scheme, called remote checksum offload,
that deals with the corner cases that are actually not able
to be handled fully by NETIF_F_HW_CSUM.
