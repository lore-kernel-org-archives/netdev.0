From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/4] phy: provide accessors for 'advertising' and
 'supported' fields
Date: Wed, 29 Jan 2014 09:14:50 -0800
Message-ID: <CAGVrzcYTuGm3s7G4cgPN4TU1j+owE5B8obfLDhhpC5autOUPFg@mail.gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com> <1390975218-13863-2-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chris Zankel <chris@zankel.net>,
	Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390975218-13863-2-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-01-28 Max Filippov <jcmvbkbc@gmail.com>:
> Many network drivers directly modify phy_device::advertising and
> phy_device::supported. Provide accessors to these fields to better
> isolate phylib from its users.
>
> Suggested-by: Ben Hutchings <ben@decadent.org.uk>
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>

After giving some more thought to this patch, I am not sure this
really adds anything, struct phy_device is already exposed to drivers,
and those drivers have been able to modify phydev->supported and
phydev->advertising to suit their needs.

> ---
> Changes v1->v2:
> - new patch
>
>  include/linux/phy.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 48a4dc3..2ae58f8 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -559,6 +559,18 @@ static inline int phy_read_status(struct phy_device *phydev) {
>         return phydev->drv->read_status(phydev);
>  }
>
> +static inline void phy_update_advert(struct phy_device *phydev, u32 clear,
> +                                    u32 set)
> +{
> +       phydev->advertising = (phydev->advertising & ~clear) | set;
> +}
> +
> +static inline void phy_update_supported(struct phy_device *phydev, u32 clear,
> +                                       u32 set)
> +{
> +       phydev->supported = (phydev->supported & ~clear) | set;
> +}
> +
>  int genphy_setup_forced(struct phy_device *phydev);
>  int genphy_restart_aneg(struct phy_device *phydev);
>  int genphy_config_aneg(struct phy_device *phydev);
> --
> 1.8.1.4
>



-- 
Florian
