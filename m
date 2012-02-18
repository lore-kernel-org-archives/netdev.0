From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3: Use *_UNKNOWN ethtool definitions
Date: Fri, 17 Feb 2012 16:54:45 -0800
Message-ID: <20120218005445.GA14067@mcarlson.broadcom.com>
References: <20120217064830.GA14483@mwanda>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org
To: "Dan Carpenter" <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2224 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038Ab2BRAzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 19:55:36 -0500
In-Reply-To: <20120217064830.GA14483@mwanda>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2012 at 09:48:30AM +0300, Dan Carpenter wrote:
> Hello Matt Carlson,
> 
> The patch e740522e6d3a: "tg3: Use *_UNKNOWN ethtool definitions" from 
> Feb 13, 2012, leads to the following Smatch warning:
> drivers/net/ethernet/broadcom/tg3.c:1822 tg3_adjust_link()
> 	 error: tp->link_config.active_speed is never equal to -1 (wrong type 0 - 65535).
> 
> -       if ((phydev->link && tp->link_config.active_speed == SPEED_INVALID) ||
> -           (!phydev->link && tp->link_config.active_speed != SPEED_INVALID) ||
> +       if ((phydev->link && tp->link_config.active_speed == SPEED_UNKNOWN) ||
> +           (!phydev->link && tp->link_config.active_speed != SPEED_UNKNOWN) ||
> 
> Since tp->link_config.active_speed is an unsigned short, it never is
> equal to SPEED_UNKNOWN (-1).
> 
> I introduced the SPEED_UNKNOWN so I feel bad that it's causing trouble
> now.  :/
> 
> Also this warning:
> drivers/net/ethernet/broadcom/tg3.c:3909 tg3_phy_copper_begin(14)
> error: tp->link_config.speed is never equal to -1 (wrong type 0 - 65535).

Do you have any problems with changing SPEED_UNKNOWN from -1 to 0xffff?
