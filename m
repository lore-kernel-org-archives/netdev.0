From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH 2/2] net: tilegx: Use helpers from linux/etherdevice.h
 to check/set MAC
Date: Wed, 28 May 2014 15:43:33 -0400
Message-ID: <53863C65.5000404@tilera.com>
References: <1401192245-26260-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:27444 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbaE1Tne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 15:43:34 -0400
In-Reply-To: <1401192245-26260-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/27/2014 8:04 AM, Tobias Klauser wrote:
> Use is_valid_ether_addr() to check for a valid MAC address to set on the
> device.  This will also check for the device address being multicast,
> which would have been possible previously.

I don't think having a multicast address here is possible (i.e. as returned
by gxio_mpipe_link_enumerate_mac), and it confuses the actual issue, which
is handling the all-zeroes case in a simulator run.  I'd prefer to see
is_zero_ether_addr() instead.

> Also use ether_addr_copy() instead of a manual memcpy() to set the
> address.
>
> Furthermore, get rid of a redundant assignment of dev->addr_len. This is
> already set by ether_setup() which is called in tile_net_setup().
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>   drivers/net/ethernet/tile/tilegx.c |   17 ++++++-----------
>   1 file changed, 6 insertions(+), 11 deletions(-)

With the change above,

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
