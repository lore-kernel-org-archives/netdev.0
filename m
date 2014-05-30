From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH 2/2] net: tilegx: Use helpers from linux/etherdevice.h
 to check/set MAC
Date: Fri, 30 May 2014 09:14:34 +0200
Message-ID: <20140530071434.GA18085@distanz.ch>
References: <1401192245-26260-1-git-send-email-tklauser@distanz.ch>
 <53863C65.5000404@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:37988 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045AbaE3HOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 03:14:37 -0400
Content-Disposition: inline
In-Reply-To: <53863C65.5000404@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-05-28 at 21:43:33 +0200, Chris Metcalf <cmetcalf@tilera.com> wrote:
> On 5/27/2014 8:04 AM, Tobias Klauser wrote:
> >Use is_valid_ether_addr() to check for a valid MAC address to set on the
> >device.  This will also check for the device address being multicast,
> >which would have been possible previously.
> 
> I don't think having a multicast address here is possible (i.e. as returned
> by gxio_mpipe_link_enumerate_mac), and it confuses the actual issue, which
> is handling the all-zeroes case in a simulator run.  I'd prefer to see
> is_zero_ether_addr() instead.

Ok, I'll send an updated patch which only tests for
!is_zero_ether_addr()

> >Also use ether_addr_copy() instead of a manual memcpy() to set the
> >address.
> >
> >Furthermore, get rid of a redundant assignment of dev->addr_len. This is
> >already set by ether_setup() which is called in tile_net_setup().
> >
> >Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> >---
> >  drivers/net/ethernet/tile/tilegx.c |   17 ++++++-----------
> >  1 file changed, 6 insertions(+), 11 deletions(-)
> 
> With the change above,
> 
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>
> 
> -- 
> Chris Metcalf, Tilera Corp.
> http://www.tilera.com
> 
