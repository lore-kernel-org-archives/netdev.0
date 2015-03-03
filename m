From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Reduce logging noise seen due to phy polling
 if link is down
Date: Tue, 03 Mar 2015 14:37:48 -0500 (EST)
Message-ID: <20150303.143748.2255336109763734319.davem@davemloft.net>
References: <1425326607-21464-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425326607-21464-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Mon,  2 Mar 2015 12:03:27 -0800

> Commit 6ce29b0e2a04 ("gianfar: Avoid unnecessary reg accesses in adjust_link()")
> eliminates unnecessary calls to adjust_link for phy devices which don't support
> interrupts and need polling. As part of that work, the 'new_state' local flag,
> which was used to reduce logging noise on the console, was eliminated.
> 
> Unfortunately, that means that a 'Link is Down' log message will now be
> issued continuously if a link is configured as UP, the link state is down,
> and the associated phy requires polling. This occurs because priv->oldduplex
> is -1 in this case, which always differs from phydev->duplex. In addition,
> phydev->speed may also differ from priv->oldspeed.  gfar_update_link_state()
> is therefore called each time a phy is polled, even if the link state did not
> change.
> 
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
