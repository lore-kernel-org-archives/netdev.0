From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 07/12] phylib: make local function static
Date: Thu, 21 Oct 2010 13:06:18 -0500
Message-ID: <9BB4BA83-AA2D-4FD3-AB02-89C0B296B179@freescale.com>
References: <20101021175045.625707607@vyatta.com> <20101021175148.610850916@vyatta.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:8258
	"EHLO AM1EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753473Ab0JUSVa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:21:30 -0400
In-Reply-To: <20101021175148.610850916@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 21, 2010, at 12:50 PM, Stephen Hemminger wrote:

> Several functions where exported but not used directly by any current
> drivers.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


At least some of these are used in drivers/of/of_mdio.c



> 
> ---
> Documentation/networking/phy.txt |   18 ------------------
> drivers/net/phy/phy.c            |   13 +++++--------
> drivers/net/phy/phy_device.c     |   18 +++++++++---------
> include/linux/phy.h              |   12 ------------
> 4 files changed, 14 insertions(+), 47 deletions(-)
> 
> --- a/drivers/net/phy/phy_device.c	2010-10-20 08:39:23.089634993 -0700
> +++ b/drivers/net/phy/phy_device.c	2010-10-20 15:00:47.015462042 -0700
> @@ -57,6 +57,9 @@ extern void mdio_bus_exit(void);
> static LIST_HEAD(phy_fixup_list);
> static DEFINE_MUTEX(phy_fixup_lock);
> 
> +static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> +			     u32 flags, phy_interface_t interface);
> +
> /*
>  * Creates a new phy_fixup and adds it to the list
>  * @bus_id: A string which matches phydev->dev.bus_id (or PHY_ANY_ID)
> @@ -146,7 +149,8 @@ int phy_scan_fixups(struct phy_device *p
> }
> EXPORT_SYMBOL(phy_scan_fixups);
> 
> -struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
> +static struct phy_device* phy_device_create(struct mii_bus *bus,
> +					    int addr, int phy_id)
> {
> 	struct phy_device *dev;
> 
> @@ -193,7 +197,6 @@ struct phy_device* phy_device_create(str
> 
> 	return dev;
> }
> -EXPORT_SYMBOL(phy_device_create);
> 
> /**
>  * get_phy_id - reads the specified addr for its ID.
> @@ -204,7 +207,7 @@ EXPORT_SYMBOL(phy_device_create);
>  * Description: Reads the ID registers of the PHY at @addr on the
>  *   @bus, stores it in @phy_id and returns zero on success.
>  */
> -int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
> +static int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
> {
> 	int phy_reg;
> 
> @@ -227,7 +230,6 @@ int get_phy_id(struct mii_bus *bus, int
> 
> 	return 0;
> }
> -EXPORT_SYMBOL(get_phy_id);
> 
> /**
>  * get_phy_device - reads the specified PHY device and returns its @phy_device struct
> @@ -316,7 +318,7 @@ EXPORT_SYMBOL(phy_find_first);
>  *   If you want to monitor your own link state, don't call
>  *   this function.
>  */
> -void phy_prepare_link(struct phy_device *phydev,
> +static void phy_prepare_link(struct phy_device *phydev,
> 		void (*handler)(struct net_device *))
> {
> 	phydev->adjust_link = handler;
> @@ -435,8 +437,8 @@ int phy_init_hw(struct phy_device *phyde
>  *     the attaching device, and given a callback for link status
>  *     change.  The phy_device is returned to the attaching driver.
>  */
> -int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> -		      u32 flags, phy_interface_t interface)
> +static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> +			     u32 flags, phy_interface_t interface)
> {
> 	struct device *d = &phydev->dev;
> 
> @@ -473,7 +475,6 @@ int phy_attach_direct(struct net_device
> 	 * (dev_flags and interface) */
> 	return phy_init_hw(phydev);
> }
> -EXPORT_SYMBOL(phy_attach_direct);
> 
> /**
>  * phy_attach - attach a network device to a particular PHY device
> @@ -540,7 +541,7 @@ EXPORT_SYMBOL(phy_detach);
>  *   what is supported.  Returns < 0 on error, 0 if the PHY's advertisement
>  *   hasn't changed, and > 0 if it has changed.
>  */
> -int genphy_config_advert(struct phy_device *phydev)
> +static int genphy_config_advert(struct phy_device *phydev)
> {
> 	u32 advertise;
> 	int oldadv, adv;
> @@ -605,7 +606,6 @@ int genphy_config_advert(struct phy_devi
> 
> 	return changed;
> }
> -EXPORT_SYMBOL(genphy_config_advert);
> 
> /**
>  * genphy_setup_forced - configures/forces speed/duplex from @phydev
> @@ -615,7 +615,7 @@ EXPORT_SYMBOL(genphy_config_advert);
>  *   to the values in phydev. Assumes that the values are valid.
>  *   Please see phy_sanitize_settings().
>  */
> -int genphy_setup_forced(struct phy_device *phydev)
> +static int genphy_setup_forced(struct phy_device *phydev)
> {
> 	int err;
> 	int ctl = 0;
> --- a/include/linux/phy.h	2010-10-20 08:39:23.109635473 -0700
> +++ b/include/linux/phy.h	2010-10-20 15:00:56.680070501 -0700
> @@ -469,14 +469,9 @@ static inline int phy_write(struct phy_d
> 	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
> }
> 
> -int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
> struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
> int phy_device_register(struct phy_device *phy);
> -int phy_clear_interrupt(struct phy_device *phydev);
> -int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
> int phy_init_hw(struct phy_device *phydev);
> -int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> -		u32 flags, phy_interface_t interface);
> struct phy_device * phy_attach(struct net_device *dev,
> 		const char *bus_id, u32 flags, phy_interface_t interface);
> struct phy_device *phy_find_first(struct mii_bus *bus);
> @@ -492,17 +487,12 @@ void phy_start(struct phy_device *phydev
> void phy_stop(struct phy_device *phydev);
> int phy_start_aneg(struct phy_device *phydev);
> 
> -void phy_sanitize_settings(struct phy_device *phydev);
> int phy_stop_interrupts(struct phy_device *phydev);
> -int phy_enable_interrupts(struct phy_device *phydev);
> -int phy_disable_interrupts(struct phy_device *phydev);
> 
> static inline int phy_read_status(struct phy_device *phydev) {
> 	return phydev->drv->read_status(phydev);
> }
> 
> -int genphy_config_advert(struct phy_device *phydev);
> -int genphy_setup_forced(struct phy_device *phydev);
> int genphy_restart_aneg(struct phy_device *phydev);
> int genphy_config_aneg(struct phy_device *phydev);
> int genphy_update_link(struct phy_device *phydev);
> @@ -511,8 +501,6 @@ int genphy_suspend(struct phy_device *ph
> int genphy_resume(struct phy_device *phydev);
> void phy_driver_unregister(struct phy_driver *drv);
> int phy_driver_register(struct phy_driver *new_driver);
> -void phy_prepare_link(struct phy_device *phydev,
> -		void (*adjust_link)(struct net_device *));
> void phy_state_machine(struct work_struct *work);
> void phy_start_machine(struct phy_device *phydev,
> 		void (*handler)(struct net_device *));
> @@ -523,7 +511,6 @@ int phy_mii_ioctl(struct phy_device *phy
> 		struct ifreq *ifr, int cmd);
> int phy_start_interrupts(struct phy_device *phydev);
> void phy_print_status(struct phy_device *phydev);
> -struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id);
> void phy_device_free(struct phy_device *phydev);
> 
> int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
> --- a/Documentation/networking/phy.txt	2010-10-20 14:56:28.262313871 -0700
> +++ b/Documentation/networking/phy.txt	2010-10-20 14:59:44.711491154 -0700
> @@ -177,18 +177,6 @@ Doing it all yourself
> 
>    A convenience function to print out the PHY status neatly.
> 
> - int phy_clear_interrupt(struct phy_device *phydev);
> - int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
> -   
> -   Clear the PHY's interrupt, and configure which ones are allowed,
> -   respectively.  Currently only supports all on, or all off.
> - 
> - int phy_enable_interrupts(struct phy_device *phydev);
> - int phy_disable_interrupts(struct phy_device *phydev);
> -
> -   Functions which enable/disable PHY interrupts, clearing them
> -   before and after, respectively.
> -
>  int phy_start_interrupts(struct phy_device *phydev);
>  int phy_stop_interrupts(struct phy_device *phydev);
> 
> @@ -213,12 +201,6 @@ Doing it all yourself
>    Fills the phydev structure with up-to-date information about the current
>    settings in the PHY.
> 
> - void phy_sanitize_settings(struct phy_device *phydev)
> -   
> -   Resolves differences between currently desired settings, and
> -   supported settings for the given PHY device.  Does not make
> -   the changes in the hardware, though.
> -
>  int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
>  int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
> 
> --- a/drivers/net/phy/phy.c	2010-10-20 14:56:28.290315833 -0700
> +++ b/drivers/net/phy/phy.c	2010-10-20 14:59:58.320365928 -0700
> @@ -65,7 +65,7 @@ EXPORT_SYMBOL(phy_print_status);
>  *
>  * Returns 0 on success on < 0 on error.
>  */
> -int phy_clear_interrupt(struct phy_device *phydev)
> +static int phy_clear_interrupt(struct phy_device *phydev)
> {
> 	int err = 0;
> 
> @@ -82,7 +82,7 @@ int phy_clear_interrupt(struct phy_devic
>  *
>  * Returns 0 on success on < 0 on error.
>  */
> -int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
> +static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
> {
> 	int err = 0;
> 
> @@ -208,7 +208,7 @@ static inline int phy_find_valid(int idx
>  *   duplexes.  Drop down by one in this order:  1000/FULL,
>  *   1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF.
>  */
> -void phy_sanitize_settings(struct phy_device *phydev)
> +static void phy_sanitize_settings(struct phy_device *phydev)
> {
> 	u32 features = phydev->supported;
> 	int idx;
> @@ -223,7 +223,6 @@ void phy_sanitize_settings(struct phy_de
> 	phydev->speed = settings[idx].speed;
> 	phydev->duplex = settings[idx].duplex;
> }
> -EXPORT_SYMBOL(phy_sanitize_settings);
> 
> /**
>  * phy_ethtool_sset - generic ethtool sset function, handles all the details
> @@ -532,7 +531,7 @@ static irqreturn_t phy_interrupt(int irq
>  * phy_enable_interrupts - Enable the interrupts from the PHY side
>  * @phydev: target phy_device struct
>  */
> -int phy_enable_interrupts(struct phy_device *phydev)
> +static int phy_enable_interrupts(struct phy_device *phydev)
> {
> 	int err;
> 
> @@ -545,13 +544,12 @@ int phy_enable_interrupts(struct phy_dev
> 
> 	return err;
> }
> -EXPORT_SYMBOL(phy_enable_interrupts);
> 
> /**
>  * phy_disable_interrupts - Disable the PHY interrupts from the PHY side
>  * @phydev: target phy_device struct
>  */
> -int phy_disable_interrupts(struct phy_device *phydev)
> +static int phy_disable_interrupts(struct phy_device *phydev)
> {
> 	int err;
> 
> @@ -574,7 +572,6 @@ phy_err:
> 
> 	return err;
> }
> -EXPORT_SYMBOL(phy_disable_interrupts);
> 
> /**
>  * phy_start_interrupts - request and enable interrupts for a PHY device
> 
> 
> 


