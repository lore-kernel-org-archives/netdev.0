From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 6/6] net: phy: Stop 'phy-state-machine' and 'phy_change'
 work on remove
Date: Tue, 27 Oct 2015 08:40:30 -0700
Message-ID: <562F9AEE.5050708@gmail.com>
References: <562F8EF1.5090504@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562F8EF1.5090504@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/10/15 07:49, Neil Armstrong wrote:
> Avoids:
>  Unable to handle kernel NULL pointer dereference at virtual address 00000064
>  Workqueue: events_power_efficient phy_state_machine
>  PC is at phy_state_machine+0x28/0x480

Stripped down oops can sometimes be missing critical pieces of
information to help debug the problem, is there a reason why this is
being obfuscated?

You are supposed to stop the PHY state machine by calling
phy_disconnect() is it possible that this is missing?

> 
> Signed-off-by: Frode Isaksen <fisaksen@baylibre.com>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  drivers/net/phy/phy_device.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 3833891..b5b6c1b 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -1348,6 +1348,12 @@ static int phy_remove(struct device *dev)
>  	phydev->state = PHY_DOWN;
>  	mutex_unlock(&phydev->lock);
> 
> +	cancel_delayed_work_sync(&phydev->state_queue);
> +	flush_delayed_work(&phydev->state_queue);
> +
> +	cancel_work_sync(&phydev->phy_queue);
> +	flush_work(&phydev->phy_queue);
> +
>  	if (phydev->drv->remove)
>  		phydev->drv->remove(phydev);
>  	phydev->drv = NULL;
> 


-- 
Florian
