From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Fri, 16 Oct 2015 17:58:41 -0500
Message-ID: <alpine.DEB.2.02.1510161749490.25648@linux-builds1>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0058.outbound.protection.outlook.com ([157.56.110.58]:18415
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751362AbbJPXFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 19:05:44 -0400
In-Reply-To: <1445028545-22599-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Oct 2015, Andrew Lunn wrote:

> Commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
> the bus' parent." broke finding PHY properties in the MAC device tree
> node. The parent device is now the MDIO bus, not the MAC. Use
> attached_dev towards the MAC device tree node.
> 
> Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> 
> Compile tested only.
> 
> Dinh, please could you test it and report back if it works or not.
>

This patch did not seem to fix the problem. The following code did seem to
fix the problem:

	if (!of_node && dev->parent->of_node)
-               of_node = dev->parent->of_node;
+       do {
+               of_node = dev->of_node;
+               dev = dev->parent;
+               i++;
+       } while (!of_node && dev);

BR,
Dinh
