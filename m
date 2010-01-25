From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] sfc: Use fixed-size buffers for MCDI NVRAM requests
Date: Mon, 25 Jan 2010 19:41:00 +0000
Message-ID: <1264448460.2793.12.camel@achroite.uk.solarflarecom.com>
References: <1264447852.2793.4.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:48394 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044Ab0AYTlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 14:41:03 -0500
In-Reply-To: <1264447852.2793.4.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-01-25 at 19:30 +0000, Ben Hutchings wrote:
> The low-level MCDI code always uses 32-bit MMIO operations, and
> callers must pad input and output buffers to multiples of 4 bytes.
> The MCDI NVRAM functions are not doing this.  Also, their buffers are
> declared as variable-length arrays with no explicit maximum length.
> 
> Switch to a fixed buffer size based on the chunk size used by the
> MTD driver (which is a multiple of 4).

This is also meant for net-2.6.  Reading or writing lengths that are not
multiples of 4 will BUG() while holding the device's MCDI lock, which
will lead to a system hang sooner or later.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

