From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 6lowpan: Uncompression of traffic class field was
 incorrect
Date: Thu, 14 Nov 2013 03:22:05 -0500 (EST)
Message-ID: <20131114.032205.1348397553819887559.davem@davemloft.net>
References: <1384333419-4087-1-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.aring@gmail.com
To: jukka.rissanen@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab3KNIWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 03:22:06 -0500
In-Reply-To: <1384333419-4087-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Date: Wed, 13 Nov 2013 11:03:39 +0200

> If priority/traffic class field in IPv6 header is set (seen when
> using ssh), the uncompression sets the TC and Flow fields incorrectly.
> 
> Example:
> 
> This is IPv6 header of a sent packet. Note the priority/TC (=1) in
> the first byte.
> 
> 00000000: 61 00 00 00 00 2c 06 40 fe 80 00 00 00 00 00 00
> 00000010: 02 02 72 ff fe c6 42 10 fe 80 00 00 00 00 00 00
> 00000020: 02 1e ab ff fe 4c 52 57
> 
> This gets compressed like this in the sending side
> 
> 00000000: 72 31 04 06 02 1e ab ff fe 4c 52 57 ec c2 00 16
> 00000010: aa 2d fe 92 86 4e be c6 ....
> 
> In the receiving end, the packet gets uncompressed to this
> IPv6 header
> 
> 00000000: 60 06 06 02 00 2a 1e 40 fe 80 00 00 00 00 00 00
> 00000010: 02 02 72 ff fe c6 42 10 fe 80 00 00 00 00 00 00
> 00000020: ab ff fe 4c 52 57 ec c2
> 
> First four bytes are set incorrectly and we have also lost
> two bytes from destination address.
> 
> The fix is to switch the case values in switch statement
> when checking the TC field.
> 
> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>

Applied, thanks.
