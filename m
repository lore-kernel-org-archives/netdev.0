From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] PHYLIB: Locking fixes for PHY I/O potentially sleeping
Date: Wed, 30 Jan 2008 03:48:43 -0500
Message-ID: <47A039EB.3000700@garzik.org>
References: <1199403419.25262.62.camel@localhost.localdomain>	 <6D762C47-9C9C-422E-A80E-CC418F624B05@freescale.com>	 <479E76A2.8020304@garzik.org> <1201622709.12444.118.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33468 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754889AbYA3Iss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:48:48 -0500
In-Reply-To: <1201622709.12444.118.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nate Case wrote:
> PHY read/write functions can potentially sleep (e.g., a PHY accessed
> via I2C).  The following changes were made to account for this:
> 
>     * Change spin locks to mutex locks
>     * Add a BUG_ON() to phy_read() phy_write() to warn against
>       calling them from an interrupt context.
>     * Use work queue for PHY state machine handling since
>       it can potentially sleep
>     * Change phydev lock from spinlock to mutex
> 
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> Acked-by: Andy Fleming <afleming@freescale.com>
> 
> ---
> Note: This is a resend of the patch submitted on January 3rd, 2008
> 
>  drivers/net/phy/mdio_bus.c   |    2 +-
>  drivers/net/phy/phy.c        |   68 ++++++++++++++++++++++++++++-------------
>  drivers/net/phy/phy_device.c |   11 +++----
>  include/linux/phy.h          |    5 ++-
>  4 files changed, 55 insertions(+), 31 deletions(-)

applied


