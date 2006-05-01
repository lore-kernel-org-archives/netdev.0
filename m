From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 4/6] tg3: Add reset_phy parameter to chip reset
 functions
Date: Mon, 01 May 2006 08:19:40 -0700
Message-ID: <1146496780.4780.38.camel@rh4>
References: <1146267368.4780.17.camel@rh4>
 <20060429.185952.101410162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:275 "EHLO mms1.broadcom.com")
	by vger.kernel.org with ESMTP id S932155AbWEAQ7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 12:59:41 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060429.185952.101410162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-04-29 at 18:59 -0700, David S. Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Fri, 28 Apr 2006 16:36:08 -0700
> 
> > Add a reset_phy parameter to tg3_reset_hw() and tg3_init_hw(). With
> > the full chip reset during MAC address change, the automatic PHY reset
> > during chip reset will cause a link down and bonding will not work
> > properly as a result. With this reset_phy parameter, we can do a chip
> > reset without link down when changing MAC address or MTU.
> > 
> > Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Applied.
> 
> Doesn't the signalling interface between the MAC and the
> PHY get reset during a chip reset and couldn't that cause
> problems if we bypass the PHY reset?

The PHY reset is needed if the PHY was previously put into low power
mode. In the cases where we reset the chip due to MTU or MAC address
changes, the power settings are not changed and therefore PHY reset is
not needed.

