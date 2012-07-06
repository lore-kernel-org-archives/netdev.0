From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/4] asix: Fix checkpatch warnings
Date: Fri, 06 Jul 2012 08:25:34 -0700
Message-ID: <1341588334.2011.21.camel@joe2Laptop>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	 <1341574388-7464-2-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46389 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750906Ab2GFPZf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 11:25:35 -0400
In-Reply-To: <1341574388-7464-2-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 13:33 +0200, Christian Riesch wrote:
>

Hi Christian.  Just some trivial comments for a
trivial cleanup patch.

> diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
> index 3ae80ec..9210f40 100644
> --- a/drivers/net/usb/asix.c
> +++ b/drivers/net/usb/asix.c
> @@ -20,8 +20,8 @@
>   * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
>   */
>  
> -// #define	DEBUG			// error path messages, extra info
> -// #define	VERBOSE			// more; success messages
> +/* #define	DEBUG	*/		/* error path messages, extra info */
> +/* #define	VERBOSE	*/		/* more; success messages */

Might as well delete as change the comment style.
It isn't applicable after the patch.

> @@ -253,8 +253,8 @@ static void asix_async_cmd_callback(struct urb *urb)
>  	int status = urb->status;
>  
>  	if (status < 0)
> -		printk(KERN_DEBUG "asix_async_cmd_callback() failed with %d",
> -			status);
> +		pr_debug("asix_async_cmd_callback() failed with %d",
> +			 status);

Probably better with "%s: "..., __func__, ...
Missing a newline too.
There are several other uses of embedded function names
that could be modified.

> @@ -432,7 +433,8 @@ static inline int asix_get_phy_addr(struct usbnet *dev)
>  	netdev_dbg(dev->net, "asix_get_phy_addr()\n");
>  
>  	if (ret < 0) {
> -		netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);
> +		netdev_err(dev->net, "Error reading PHYID register: %02x\n",
> +			   ret);

80 column zealotry?  If you want, but it's probably past
the time that's really desirable or necessary.

> @@ -575,7 +580,7 @@ static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
>  	mutex_lock(&dev->phy_mutex);
>  	asix_set_sw_mii(dev);
>  	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
> -				(__u16)loc, 2, &res);
> +		      (__u16)loc, 2, &res);

Fits on 1 line.

> +static void asix_get_drvinfo(struct net_device *net,
> +			     struct ethtool_drvinfo *info)
>  {
>  	struct usbnet *dev = netdev_priv(net);
>  	struct asix_data *data = (struct asix_data *)&dev->data;
>  
>  	/* Inherit standard device info */
>  	usbnet_get_drvinfo(net, info);
> -	strncpy (info->driver, DRIVER_NAME, sizeof info->driver);
> -	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
> +	strncpy(info->driver, DRIVER_NAME, sizeof info->driver);
> +	strncpy(info->version, DRIVER_VERSION, sizeof info->version);

Most every kernel use of sizeof uses parens like:

	strncpy(info->driver, DRIVER_NAME, sizeof(info->driver));
	strncpy(info->version, DRIVER_VERSION, sizeof(info->version));
 
@@ -1510,133 +1520,133 @@ static const struct driver_info ax88178_info = {
>  	.tx_fixup = asix_tx_fixup,
>  };
>  
> -static const struct usb_device_id	products [] = {
> +static const struct usb_device_id	products[] = {

Maybe use a space not a tab after usb_device_id.

>  {
> -	// Linksys USB200M
> -	USB_DEVICE (0x077b, 0x2226),
> +	/* Linksys USB200M */
> +	USB_DEVICE(0x077b, 0x2226),
>  	.driver_info =	(unsigned long) &ax8817x_info,
>  }, {

I think all of these would look more reasonable on single
lines like

	{ USB_DEVICE(0xxxxx, 0xxxxx), .driver_info = (unsigned long)&func },

or maybe add another macro like:

#define ASIX_USB_DEVICE(vendor, product, driver)	\
	USB_DEVICE(vendor, product), .driver_info = (unsigned long)driver)

and make these

	{ ASIX_USB_DEVICE(0xxxxx, 0xxxxx, &func) },	/* description */

Come to think of it, the & for the function address
isn't necessary either.

cheers, Joe
