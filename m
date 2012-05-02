From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Subject: Re: [PATCH 01/13 v4] usb/net: rndis: inline the cpu_to_le32()
 macro
Date: Wed, 02 May 2012 18:29:38 +0300
Message-ID: <20120502182938.15804ij32yd8jsis@www.81.fi>
References: <1335896538-13281-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_4f7pu51v4tus"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1335896538-13281-1-git-send-email-linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message is in MIME format.

--=_4f7pu51v4tus
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Quoting Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>:

> The header file <linux/usb/rndis_host.h> used a number of #defines
> that included the cpu_to_le32() macro to assure the result will be
> in LE endianness. Inlining this into the code instead of using it
> in the code definitions yields consolidation opportunities later
> on as you will see in the following patches. The individual
> drivers also used local defines - all are switched over to the
> pattern of doing the conversion at the call sites instead.
>

After this patch, endianness checks with sparse output:

   CHECK   drivers/net/usb/rndis_host.c
drivers/net/usb/rndis_host.c:152:18: warning: restricted __le32  
degrades to integer
drivers/net/usb/rndis_host.c:152:13: warning: incorrect type in  
assignment (different base types)
drivers/net/usb/rndis_host.c:152:13:    expected restricted __le32  
[usertype] rsp
drivers/net/usb/rndis_host.c:152:13:    got unsigned int

   CHECK   drivers/net/wireless/rndis_wlan.c
drivers/net/wireless/rndis_wlan.c:2627:38: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:2627:38:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:2627:38:    got int
drivers/net/wireless/rndis_wlan.c:2657:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:2657:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:2657:37:    got int
drivers/net/wireless/rndis_wlan.c:1258:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1258:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1258:37:    got int
drivers/net/wireless/rndis_wlan.c:2116:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:2116:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:2116:39:    got int
drivers/net/wireless/rndis_wlan.c:1036:38: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1036:38:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1036:38:    got int
drivers/net/wireless/rndis_wlan.c:1045:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1045:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1045:37:    got int
drivers/net/wireless/rndis_wlan.c:1062:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1062:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1062:37:    got int
drivers/net/wireless/rndis_wlan.c:1086:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1086:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1086:39:    got int
drivers/net/wireless/rndis_wlan.c:1097:40: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1097:40:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1097:40:    got int
drivers/net/wireless/rndis_wlan.c:1122:45: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1122:45:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1122:45:    got int
drivers/net/wireless/rndis_wlan.c:1184:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1184:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1184:37:    got int
drivers/net/wireless/rndis_wlan.c:1211:38: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1211:38:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1211:38:    got int
drivers/net/wireless/rndis_wlan.c:1237:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1237:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1237:37:    got int
drivers/net/wireless/rndis_wlan.c:1285:38: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1285:38:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1285:38:    got int
drivers/net/wireless/rndis_wlan.c:1299:38: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1299:38:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1299:38:    got int
drivers/net/wireless/rndis_wlan.c:1336:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1336:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1336:39:    got int
drivers/net/wireless/rndis_wlan.c:1344:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1344:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1344:37:    got int
drivers/net/wireless/rndis_wlan.c:1362:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1362:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1362:39:    got int
drivers/net/wireless/rndis_wlan.c:1416:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1416:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1416:37:    got int
drivers/net/wireless/rndis_wlan.c:1507:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1507:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1507:37:    got int
drivers/net/wireless/rndis_wlan.c:1597:45: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1597:45:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1597:45:    got int
drivers/net/wireless/rndis_wlan.c:1603:45: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1603:45:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1603:45:    got int
drivers/net/wireless/rndis_wlan.c:1672:45: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1672:45:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1672:45:    got int
drivers/net/wireless/rndis_wlan.c:1685:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1685:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1685:37:    got int
drivers/net/wireless/rndis_wlan.c:1751:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1751:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1751:39:    got int
drivers/net/wireless/rndis_wlan.c:1779:37: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:1779:37:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:1779:37:    got int
drivers/net/wireless/rndis_wlan.c:2514:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:2514:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:2514:39:    got int
drivers/net/wireless/rndis_wlan.c:2521:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:2521:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:2521:39:    got int
drivers/net/wireless/rndis_wlan.c:2696:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:2696:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:2696:39:    got int
drivers/net/wireless/rndis_wlan.c:2723:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:2723:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:2723:39:    got int
drivers/net/wireless/rndis_wlan.c:3100:25: warning: restricted __le32  
degrades to integer
drivers/net/wireless/rndis_wlan.c:3151:42: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:3151:42:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:3151:42:    got int
drivers/net/wireless/rndis_wlan.c:3176:42: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:3176:42:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:3176:42:    got int
drivers/net/wireless/rndis_wlan.c:3250:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:3250:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:3250:39:    got int
drivers/net/wireless/rndis_wlan.c:3278:39: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:3278:39:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:3278:39:    got int
drivers/net/wireless/rndis_wlan.c:3286:41: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:3286:41:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:3286:41:    got int
drivers/net/wireless/rndis_wlan.c:3606:31: warning: incorrect type in  
argument 2 (different base types)
drivers/net/wireless/rndis_wlan.c:3606:31:    expected restricted  
__le32 [usertype] oid
drivers/net/wireless/rndis_wlan.c:3606:31:    got int

Patch fixing this attached.

Patch-set to clean-up ugliness caused by this patch at:  
http://koti.mbnet.fi/axh/kernel/rndis_wlan/

-Jussi

> Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/usb/rndis_host.c      |   52 +++++++-------
>  drivers/net/wireless/rndis_wlan.c |  138  
> +++++++++++++++++++------------------
>  include/linux/usb/rndis_host.h    |   84 +++++++++++-----------
>  3 files changed, 139 insertions(+), 135 deletions(-)
>
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index c8f1b5b..05cad0b 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -78,10 +78,10 @@ static void rndis_msg_indicate(struct usbnet  
> *dev, struct rndis_indicate *msg,
>  		dev->driver_info->indication(dev, msg, buflen);
>  	} else {
>  		switch (msg->status) {
> -		case RNDIS_STATUS_MEDIA_CONNECT:
> +		case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNECT):
>  			dev_info(udev, "rndis media connect\n");
>  			break;
> -		case RNDIS_STATUS_MEDIA_DISCONNECT:
> +		case cpu_to_le32(RNDIS_STATUS_MEDIA_DISCONNECT):
>  			dev_info(udev, "rndis media disconnect\n");
>  			break;
>  		default:
> @@ -117,8 +117,8 @@ int rndis_command(struct usbnet *dev, struct  
> rndis_msg_hdr *buf, int buflen)
>  	 */
>
>  	/* Issue the request; xid is unique, don't bother byteswapping it */
> -	if (likely(buf->msg_type != RNDIS_MSG_HALT &&
> -		   buf->msg_type != RNDIS_MSG_RESET)) {
> +	if (likely(buf->msg_type != cpu_to_le32(RNDIS_MSG_HALT) &&
> +		   buf->msg_type != cpu_to_le32(RNDIS_MSG_RESET))) {
>  		xid = dev->xid++;
>  		if (!xid)
>  			xid = dev->xid++;
> @@ -164,9 +164,10 @@ int rndis_command(struct usbnet *dev, struct  
> rndis_msg_hdr *buf, int buflen)
>  			request_id = (__force u32) buf->request_id;
>  			if (likely(buf->msg_type == rsp)) {
>  				if (likely(request_id == xid)) {
> -					if (unlikely(rsp == RNDIS_MSG_RESET_C))
> +					if (unlikely(rsp ==
> +					    cpu_to_le32(RNDIS_MSG_RESET_C)))
>  						return 0;
> -					if (likely(RNDIS_STATUS_SUCCESS
> +					if (likely(cpu_to_le32(RNDIS_STATUS_SUCCESS)
>  							== buf->status))
>  						return 0;
>  					dev_dbg(&info->control->dev,
> @@ -179,16 +180,15 @@ int rndis_command(struct usbnet *dev, struct  
> rndis_msg_hdr *buf, int buflen)
>  					request_id, xid);
>  				/* then likely retry */
>  			} else switch (buf->msg_type) {
> -			case RNDIS_MSG_INDICATE:	/* fault/event */
> +			case cpu_to_le32(RNDIS_MSG_INDICATE): /* fault/event */
>  				rndis_msg_indicate(dev, (void *)buf, buflen);
> -
>  				break;
> -			case RNDIS_MSG_KEEPALIVE: {	/* ping */
> +			case cpu_to_le32(RNDIS_MSG_KEEPALIVE): { /* ping */
>  				struct rndis_keepalive_c *msg = (void *)buf;
>
> -				msg->msg_type = RNDIS_MSG_KEEPALIVE_C;
> +				msg->msg_type = cpu_to_le32(RNDIS_MSG_KEEPALIVE_C);
>  				msg->msg_len = cpu_to_le32(sizeof *msg);
> -				msg->status = RNDIS_STATUS_SUCCESS;
> +				msg->status = cpu_to_le32(RNDIS_STATUS_SUCCESS);
>  				retval = usb_control_msg(dev->udev,
>  					usb_sndctrlpipe(dev->udev, 0),
>  					USB_CDC_SEND_ENCAPSULATED_COMMAND,
> @@ -251,7 +251,7 @@ static int rndis_query(struct usbnet *dev,  
> struct usb_interface *intf,
>  	u.buf = buf;
>
>  	memset(u.get, 0, sizeof *u.get + in_len);
> -	u.get->msg_type = RNDIS_MSG_QUERY;
> +	u.get->msg_type = cpu_to_le32(RNDIS_MSG_QUERY);
>  	u.get->msg_len = cpu_to_le32(sizeof *u.get + in_len);
>  	u.get->oid = oid;
>  	u.get->len = cpu_to_le32(in_len);
> @@ -324,7 +324,7 @@ generic_rndis_bind(struct usbnet *dev, struct  
> usb_interface *intf, int flags)
>  	if (retval < 0)
>  		goto fail;
>
> -	u.init->msg_type = RNDIS_MSG_INIT;
> +	u.init->msg_type = cpu_to_le32(RNDIS_MSG_INIT);
>  	u.init->msg_len = cpu_to_le32(sizeof *u.init);
>  	u.init->major_version = cpu_to_le32(1);
>  	u.init->minor_version = cpu_to_le32(0);
> @@ -395,22 +395,23 @@ generic_rndis_bind(struct usbnet *dev, struct  
> usb_interface *intf, int flags)
>  	/* Check physical medium */
>  	phym = NULL;
>  	reply_len = sizeof *phym;
> -	retval = rndis_query(dev, intf, u.buf, OID_GEN_PHYSICAL_MEDIUM,
> +	retval = rndis_query(dev, intf, u.buf,
> +			     cpu_to_le32(OID_GEN_PHYSICAL_MEDIUM),
>  			0, (void **) &phym, &reply_len);
>  	if (retval != 0 || !phym) {
>  		/* OID is optional so don't fail here. */
> -		phym_unspec = RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED;
> +		phym_unspec = cpu_to_le32(RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED);
>  		phym = &phym_unspec;
>  	}
>  	if ((flags & FLAG_RNDIS_PHYM_WIRELESS) &&
> -			*phym != RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
> +	    *phym != cpu_to_le32(RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN)) {
>  		netif_dbg(dev, probe, dev->net,
>  			  "driver requires wireless physical medium, but device is not\n");
>  		retval = -ENODEV;
>  		goto halt_fail_and_release;
>  	}
>  	if ((flags & FLAG_RNDIS_PHYM_NOT_WIRELESS) &&
> -			*phym == RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
> +	    *phym == cpu_to_le32(RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN)) {
>  		netif_dbg(dev, probe, dev->net,
>  			  "driver requires non-wireless physical medium, but device is  
> wireless.\n");
>  		retval = -ENODEV;
> @@ -419,7 +420,8 @@ generic_rndis_bind(struct usbnet *dev, struct  
> usb_interface *intf, int flags)
>
>  	/* Get designated host ethernet address */
>  	reply_len = ETH_ALEN;
> -	retval = rndis_query(dev, intf, u.buf, OID_802_3_PERMANENT_ADDRESS,
> +	retval = rndis_query(dev, intf, u.buf,
> +			     cpu_to_le32(OID_802_3_PERMANENT_ADDRESS),
>  			48, (void **) &bp, &reply_len);
>  	if (unlikely(retval< 0)) {
>  		dev_err(&intf->dev, "rndis get ethaddr, %d\n", retval);
> @@ -430,12 +432,12 @@ generic_rndis_bind(struct usbnet *dev, struct  
> usb_interface *intf, int flags)
>
>  	/* set a nonzero filter to enable data transfers */
>  	memset(u.set, 0, sizeof *u.set);
> -	u.set->msg_type = RNDIS_MSG_SET;
> +	u.set->msg_type = cpu_to_le32(RNDIS_MSG_SET);
>  	u.set->msg_len = cpu_to_le32(4 + sizeof *u.set);
> -	u.set->oid = OID_GEN_CURRENT_PACKET_FILTER;
> +	u.set->oid = cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER);
>  	u.set->len = cpu_to_le32(4);
>  	u.set->offset = cpu_to_le32((sizeof *u.set) - 8);
> -	*(__le32 *)(u.buf + sizeof *u.set) = RNDIS_DEFAULT_FILTER;
> +	*(__le32 *)(u.buf + sizeof *u.set) = cpu_to_le32(RNDIS_DEFAULT_FILTER);
>
>  	retval = rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
>  	if (unlikely(retval < 0)) {
> @@ -450,7 +452,7 @@ generic_rndis_bind(struct usbnet *dev, struct  
> usb_interface *intf, int flags)
>
>  halt_fail_and_release:
>  	memset(u.halt, 0, sizeof *u.halt);
> -	u.halt->msg_type = RNDIS_MSG_HALT;
> +	u.halt->msg_type = cpu_to_le32(RNDIS_MSG_HALT);
>  	u.halt->msg_len = cpu_to_le32(sizeof *u.halt);
>  	(void) rndis_command(dev, (void *)u.halt, CONTROL_BUFFER_SIZE);
>  fail_and_release:
> @@ -475,7 +477,7 @@ void rndis_unbind(struct usbnet *dev, struct  
> usb_interface *intf)
>  	/* try to clear any rndis state/activity (no i/o from stack!) */
>  	halt = kzalloc(CONTROL_BUFFER_SIZE, GFP_KERNEL);
>  	if (halt) {
> -		halt->msg_type = RNDIS_MSG_HALT;
> +		halt->msg_type = cpu_to_le32(RNDIS_MSG_HALT);
>  		halt->msg_len = cpu_to_le32(sizeof *halt);
>  		(void) rndis_command(dev, (void *)halt, CONTROL_BUFFER_SIZE);
>  		kfree(halt);
> @@ -501,7 +503,7 @@ int rndis_rx_fixup(struct usbnet *dev, struct  
> sk_buff *skb)
>  		data_len = le32_to_cpu(hdr->data_len);
>
>  		/* don't choke if we see oob, per-packet data, etc */
> -		if (unlikely(hdr->msg_type != RNDIS_MSG_PACKET ||
> +		if (unlikely(hdr->msg_type != cpu_to_le32(RNDIS_MSG_PACKET) ||
>  			     skb->len < msg_len ||
>  			     (data_offset + data_len + 8) > msg_len)) {
>  			dev->net->stats.rx_frame_errors++;
> @@ -569,7 +571,7 @@ rndis_tx_fixup(struct usbnet *dev, struct  
> sk_buff *skb, gfp_t flags)
>  fill:
>  	hdr = (void *) __skb_push(skb, sizeof *hdr);
>  	memset(hdr, 0, sizeof *hdr);
> -	hdr->msg_type = RNDIS_MSG_PACKET;
> +	hdr->msg_type = cpu_to_le32(RNDIS_MSG_PACKET);
>  	hdr->msg_len = cpu_to_le32(skb->len);
>  	hdr->data_offset = cpu_to_le32(sizeof(*hdr) - 8);
>  	hdr->data_len = cpu_to_le32(len);
> diff --git a/drivers/net/wireless/rndis_wlan.c  
> b/drivers/net/wireless/rndis_wlan.c
> index d66e298..a935012 100644
> --- a/drivers/net/wireless/rndis_wlan.c
> +++ b/drivers/net/wireless/rndis_wlan.c
> @@ -90,45 +90,45 @@ MODULE_PARM_DESC(workaround_interval,
>
>
>  /* various RNDIS OID defs */
> -#define OID_GEN_LINK_SPEED			cpu_to_le32(0x00010107)
> -#define OID_GEN_RNDIS_CONFIG_PARAMETER		cpu_to_le32(0x0001021b)
> -
> -#define OID_GEN_XMIT_OK				cpu_to_le32(0x00020101)
> -#define OID_GEN_RCV_OK				cpu_to_le32(0x00020102)
> -#define OID_GEN_XMIT_ERROR			cpu_to_le32(0x00020103)
> -#define OID_GEN_RCV_ERROR			cpu_to_le32(0x00020104)
> -#define OID_GEN_RCV_NO_BUFFER			cpu_to_le32(0x00020105)
> -
> -#define OID_802_3_CURRENT_ADDRESS		cpu_to_le32(0x01010102)
> -#define OID_802_3_MULTICAST_LIST		cpu_to_le32(0x01010103)
> -#define OID_802_3_MAXIMUM_LIST_SIZE		cpu_to_le32(0x01010104)
> -
> -#define OID_802_11_BSSID			cpu_to_le32(0x0d010101)
> -#define OID_802_11_SSID				cpu_to_le32(0x0d010102)
> -#define OID_802_11_INFRASTRUCTURE_MODE		cpu_to_le32(0x0d010108)
> -#define OID_802_11_ADD_WEP			cpu_to_le32(0x0d010113)
> -#define OID_802_11_REMOVE_WEP			cpu_to_le32(0x0d010114)
> -#define OID_802_11_DISASSOCIATE			cpu_to_le32(0x0d010115)
> -#define OID_802_11_AUTHENTICATION_MODE		cpu_to_le32(0x0d010118)
> -#define OID_802_11_PRIVACY_FILTER		cpu_to_le32(0x0d010119)
> -#define OID_802_11_BSSID_LIST_SCAN		cpu_to_le32(0x0d01011a)
> -#define OID_802_11_ENCRYPTION_STATUS		cpu_to_le32(0x0d01011b)
> -#define OID_802_11_ADD_KEY			cpu_to_le32(0x0d01011d)
> -#define OID_802_11_REMOVE_KEY			cpu_to_le32(0x0d01011e)
> -#define OID_802_11_ASSOCIATION_INFORMATION	cpu_to_le32(0x0d01011f)
> -#define OID_802_11_CAPABILITY			cpu_to_le32(0x0d010122)
> -#define OID_802_11_PMKID			cpu_to_le32(0x0d010123)
> -#define OID_802_11_NETWORK_TYPES_SUPPORTED	cpu_to_le32(0x0d010203)
> -#define OID_802_11_NETWORK_TYPE_IN_USE		cpu_to_le32(0x0d010204)
> -#define OID_802_11_TX_POWER_LEVEL		cpu_to_le32(0x0d010205)
> -#define OID_802_11_RSSI				cpu_to_le32(0x0d010206)
> -#define OID_802_11_RSSI_TRIGGER			cpu_to_le32(0x0d010207)
> -#define OID_802_11_FRAGMENTATION_THRESHOLD	cpu_to_le32(0x0d010209)
> -#define OID_802_11_RTS_THRESHOLD		cpu_to_le32(0x0d01020a)
> -#define OID_802_11_SUPPORTED_RATES		cpu_to_le32(0x0d01020e)
> -#define OID_802_11_CONFIGURATION		cpu_to_le32(0x0d010211)
> -#define OID_802_11_POWER_MODE			cpu_to_le32(0x0d010216)
> -#define OID_802_11_BSSID_LIST			cpu_to_le32(0x0d010217)
> +#define OID_GEN_LINK_SPEED			0x00010107
> +#define OID_GEN_RNDIS_CONFIG_PARAMETER		0x0001021b
> +
> +#define OID_GEN_XMIT_OK				0x00020101
> +#define OID_GEN_RCV_OK				0x00020102
> +#define OID_GEN_XMIT_ERROR			0x00020103
> +#define OID_GEN_RCV_ERROR			0x00020104
> +#define OID_GEN_RCV_NO_BUFFER			0x00020105
> +
> +#define OID_802_3_CURRENT_ADDRESS		0x01010102
> +#define OID_802_3_MULTICAST_LIST		0x01010103
> +#define OID_802_3_MAXIMUM_LIST_SIZE		0x01010104
> +
> +#define OID_802_11_BSSID			0x0d010101
> +#define OID_802_11_SSID				0x0d010102
> +#define OID_802_11_INFRASTRUCTURE_MODE		0x0d010108
> +#define OID_802_11_ADD_WEP			0x0d010113
> +#define OID_802_11_REMOVE_WEP			0x0d010114
> +#define OID_802_11_DISASSOCIATE			0x0d010115
> +#define OID_802_11_AUTHENTICATION_MODE		0x0d010118
> +#define OID_802_11_PRIVACY_FILTER		0x0d010119
> +#define OID_802_11_BSSID_LIST_SCAN		0x0d01011a
> +#define OID_802_11_ENCRYPTION_STATUS		0x0d01011b
> +#define OID_802_11_ADD_KEY			0x0d01011d
> +#define OID_802_11_REMOVE_KEY			0x0d01011e
> +#define OID_802_11_ASSOCIATION_INFORMATION	0x0d01011f
> +#define OID_802_11_CAPABILITY			0x0d010122
> +#define OID_802_11_PMKID			0x0d010123
> +#define OID_802_11_NETWORK_TYPES_SUPPORTED	0x0d010203
> +#define OID_802_11_NETWORK_TYPE_IN_USE		0x0d010204
> +#define OID_802_11_TX_POWER_LEVEL		0x0d010205
> +#define OID_802_11_RSSI				0x0d010206
> +#define OID_802_11_RSSI_TRIGGER			0x0d010207
> +#define OID_802_11_FRAGMENTATION_THRESHOLD	0x0d010209
> +#define OID_802_11_RTS_THRESHOLD		0x0d01020a
> +#define OID_802_11_SUPPORTED_RATES		0x0d01020e
> +#define OID_802_11_CONFIGURATION		0x0d010211
> +#define OID_802_11_POWER_MODE			0x0d010216
> +#define OID_802_11_BSSID_LIST			0x0d010217
>
>
>  /* Typical noise/maximum signal level values taken from ndiswrapper  
> iw_ndis.h */
> @@ -151,8 +151,8 @@ MODULE_PARM_DESC(workaround_interval,
>
>
>  /* codes for "status" field of completion messages */
> -#define RNDIS_STATUS_ADAPTER_NOT_READY		cpu_to_le32(0xc0010011)
> -#define RNDIS_STATUS_ADAPTER_NOT_OPEN		cpu_to_le32(0xc0010012)
> +#define RNDIS_STATUS_ADAPTER_NOT_READY		0xc0010011
> +#define RNDIS_STATUS_ADAPTER_NOT_OPEN		0xc0010012
>
>
>  /* Known device types */
> @@ -673,7 +673,7 @@ static int rndis_akm_suite_to_key_mgmt(u32 akm_suite)
>  static const char *oid_to_string(__le32 oid)
>  {
>  	switch (oid) {
> -#define OID_STR(oid) case oid: return(#oid)
> +#define OID_STR(oid) case cpu_to_le32(oid): return(#oid)
>  		/* from rndis_host.h */
>  		OID_STR(OID_802_3_PERMANENT_ADDRESS);
>  		OID_STR(OID_GEN_MAXIMUM_FRAME_SIZE);
> @@ -737,18 +737,18 @@ static int rndis_error_status(__le32 rndis_status)
>  {
>  	int ret = -EINVAL;
>  	switch (rndis_status) {
> -	case RNDIS_STATUS_SUCCESS:
> +	case cpu_to_le32(RNDIS_STATUS_SUCCESS):
>  		ret = 0;
>  		break;
> -	case RNDIS_STATUS_FAILURE:
> -	case RNDIS_STATUS_INVALID_DATA:
> +	case cpu_to_le32(RNDIS_STATUS_FAILURE):
> +	case cpu_to_le32(RNDIS_STATUS_INVALID_DATA):
>  		ret = -EINVAL;
>  		break;
> -	case RNDIS_STATUS_NOT_SUPPORTED:
> +	case cpu_to_le32(RNDIS_STATUS_NOT_SUPPORTED):
>  		ret = -EOPNOTSUPP;
>  		break;
> -	case RNDIS_STATUS_ADAPTER_NOT_READY:
> -	case RNDIS_STATUS_ADAPTER_NOT_OPEN:
> +	case cpu_to_le32(RNDIS_STATUS_ADAPTER_NOT_READY):
> +	case cpu_to_le32(RNDIS_STATUS_ADAPTER_NOT_OPEN):
>  		ret = -EBUSY;
>  		break;
>  	}
> @@ -782,7 +782,7 @@ static int rndis_query_oid(struct usbnet *dev,  
> __le32 oid, void *data, int *len)
>  	mutex_lock(&priv->command_lock);
>
>  	memset(u.get, 0, sizeof *u.get);
> -	u.get->msg_type = RNDIS_MSG_QUERY;
> +	u.get->msg_type = cpu_to_le32(RNDIS_MSG_QUERY);
>  	u.get->msg_len = cpu_to_le32(sizeof *u.get);
>  	u.get->oid = oid;
>
> @@ -866,7 +866,7 @@ static int rndis_set_oid(struct usbnet *dev,  
> __le32 oid, const void *data,
>  	mutex_lock(&priv->command_lock);
>
>  	memset(u.set, 0, sizeof *u.set);
> -	u.set->msg_type = RNDIS_MSG_SET;
> +	u.set->msg_type = cpu_to_le32(RNDIS_MSG_SET);
>  	u.set->msg_len = cpu_to_le32(sizeof(*u.set) + len);
>  	u.set->oid = oid;
>  	u.set->len = cpu_to_le32(len);
> @@ -908,7 +908,7 @@ static int rndis_reset(struct usbnet *usbdev)
>
>  	reset = (void *)priv->command_buffer;
>  	memset(reset, 0, sizeof(*reset));
> -	reset->msg_type = RNDIS_MSG_RESET;
> +	reset->msg_type = cpu_to_le32(RNDIS_MSG_RESET);
>  	reset->msg_len = cpu_to_le32(sizeof(*reset));
>  	priv->current_command_oid = 0;
>  	ret = rndis_command(usbdev, (void *)reset, CONTROL_BUFFER_SIZE);
> @@ -994,7 +994,7 @@ static int rndis_set_config_parameter(struct  
> usbnet *dev, char *param,
>  	}
>  #endif
>
> -	ret = rndis_set_oid(dev, OID_GEN_RNDIS_CONFIG_PARAMETER,
> +	ret = rndis_set_oid(dev, cpu_to_le32(OID_GEN_RNDIS_CONFIG_PARAMETER),
>  							infobuf, info_len);
>  	if (ret != 0)
>  		netdev_dbg(dev->net, "setting rndis config parameter failed, %d\n",
> @@ -1626,14 +1626,14 @@ static void set_multicast_list(struct usbnet *usbdev)
>  	char *mc_addrs = NULL;
>  	int mc_count;
>
> -	basefilter = filter = RNDIS_PACKET_TYPE_DIRECTED |
> -			      RNDIS_PACKET_TYPE_BROADCAST;
> +	basefilter = filter = cpu_to_le32(RNDIS_PACKET_TYPE_DIRECTED |
> +					  RNDIS_PACKET_TYPE_BROADCAST);
>
>  	if (usbdev->net->flags & IFF_PROMISC) {
> -		filter |= RNDIS_PACKET_TYPE_PROMISCUOUS |
> -			RNDIS_PACKET_TYPE_ALL_LOCAL;
> +		filter |= cpu_to_le32(RNDIS_PACKET_TYPE_PROMISCUOUS |
> +				      RNDIS_PACKET_TYPE_ALL_LOCAL);
>  	} else if (usbdev->net->flags & IFF_ALLMULTI) {
> -		filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
> +		filter |= cpu_to_le32(RNDIS_PACKET_TYPE_ALL_MULTICAST);
>  	}
>
>  	if (filter != basefilter)
> @@ -1646,7 +1646,7 @@ static void set_multicast_list(struct usbnet *usbdev)
>  	netif_addr_lock_bh(usbdev->net);
>  	mc_count = netdev_mc_count(usbdev->net);
>  	if (mc_count > priv->multicast_size) {
> -		filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
> +		filter |= cpu_to_le32(RNDIS_PACKET_TYPE_ALL_MULTICAST);
>  	} else if (mc_count) {
>  		int i = 0;
>
> @@ -1673,9 +1673,9 @@ static void set_multicast_list(struct usbnet *usbdev)
>  				    mc_count * ETH_ALEN);
>  		kfree(mc_addrs);
>  		if (ret == 0)
> -			filter |= RNDIS_PACKET_TYPE_MULTICAST;
> +			filter |= cpu_to_le32(RNDIS_PACKET_TYPE_MULTICAST);
>  		else
> -			filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
> +			filter |= cpu_to_le32(RNDIS_PACKET_TYPE_ALL_MULTICAST);
>
>  		netdev_dbg(usbdev->net, "OID_802_3_MULTICAST_LIST(%d, max: %d) -> %d\n",
>  			   mc_count, priv->multicast_size, ret);
> @@ -3096,7 +3096,7 @@ static void rndis_wlan_indication(struct  
> usbnet *usbdev, void *ind, int buflen)
>  	struct rndis_indicate *msg = ind;
>
>  	switch (msg->status) {
> -	case RNDIS_STATUS_MEDIA_CONNECT:
> +	case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNECT):
>  		if (priv->current_command_oid == OID_802_11_ADD_KEY) {
>  			/* OID_802_11_ADD_KEY causes sometimes extra
>  			 * "media connect" indications which confuses driver
> @@ -3116,7 +3116,7 @@ static void rndis_wlan_indication(struct  
> usbnet *usbdev, void *ind, int buflen)
>  		queue_work(priv->workqueue, &priv->work);
>  		break;
>
> -	case RNDIS_STATUS_MEDIA_DISCONNECT:
> +	case cpu_to_le32(RNDIS_STATUS_MEDIA_DISCONNECT):
>  		netdev_info(usbdev->net, "media disconnect\n");
>
>  		/* queue work to avoid recursive calls into rndis_command */
> @@ -3124,7 +3124,7 @@ static void rndis_wlan_indication(struct  
> usbnet *usbdev, void *ind, int buflen)
>  		queue_work(priv->workqueue, &priv->work);
>  		break;
>
> -	case RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION:
> +	case cpu_to_le32(RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION):
>  		rndis_wlan_media_specific_indication(usbdev, msg, buflen);
>  		break;
>
> @@ -3465,13 +3465,15 @@ static int rndis_wlan_bind(struct usbnet  
> *usbdev, struct usb_interface *intf)
>  	 */
>  	usbdev->net->netdev_ops = &rndis_wlan_netdev_ops;
>
> -	tmp = RNDIS_PACKET_TYPE_DIRECTED | RNDIS_PACKET_TYPE_BROADCAST;
> -	retval = rndis_set_oid(usbdev, OID_GEN_CURRENT_PACKET_FILTER, &tmp,
> -								sizeof(tmp));
> +	tmp = cpu_to_le32(RNDIS_PACKET_TYPE_DIRECTED |  
> RNDIS_PACKET_TYPE_BROADCAST);
> +	retval = rndis_set_oid(usbdev,
> +			       cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER),
> +			       &tmp, sizeof(tmp));
>
>  	len = sizeof(tmp);
> -	retval = rndis_query_oid(usbdev, OID_802_3_MAXIMUM_LIST_SIZE, &tmp,
> -								&len);
> +	retval = rndis_query_oid(usbdev,
> +				 cpu_to_le32(OID_802_3_MAXIMUM_LIST_SIZE),
> +				 &tmp, &len);
>  	priv->multicast_size = le32_to_cpu(tmp);
>  	if (retval < 0 || priv->multicast_size < 0)
>  		priv->multicast_size = 0;
> diff --git a/include/linux/usb/rndis_host.h b/include/linux/usb/rndis_host.h
> index 88fceb7..9a005b6 100644
> --- a/include/linux/usb/rndis_host.h
> +++ b/include/linux/usb/rndis_host.h
> @@ -49,46 +49,46 @@ struct rndis_msg_hdr {
>   */
>  #define	RNDIS_CONTROL_TIMEOUT_MS	(5 * 1000)
>
> -#define RNDIS_MSG_COMPLETION	cpu_to_le32(0x80000000)
> +#define RNDIS_MSG_COMPLETION	0x80000000
>
>  /* codes for "msg_type" field of rndis messages;
>   * only the data channel uses packet messages (maybe batched);
>   * everything else goes on the control channel.
>   */
> -#define RNDIS_MSG_PACKET	cpu_to_le32(0x00000001)	/* 1-N packets */
> -#define RNDIS_MSG_INIT		cpu_to_le32(0x00000002)
> +#define RNDIS_MSG_PACKET	0x00000001	/* 1-N packets */
> +#define RNDIS_MSG_INIT		0x00000002
>  #define RNDIS_MSG_INIT_C	(RNDIS_MSG_INIT|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_HALT		cpu_to_le32(0x00000003)
> -#define RNDIS_MSG_QUERY		cpu_to_le32(0x00000004)
> +#define RNDIS_MSG_HALT		0x00000003
> +#define RNDIS_MSG_QUERY		0x00000004
>  #define RNDIS_MSG_QUERY_C	(RNDIS_MSG_QUERY|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_SET		cpu_to_le32(0x00000005)
> +#define RNDIS_MSG_SET		0x00000005
>  #define RNDIS_MSG_SET_C		(RNDIS_MSG_SET|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_RESET		cpu_to_le32(0x00000006)
> +#define RNDIS_MSG_RESET		0x00000006
>  #define RNDIS_MSG_RESET_C	(RNDIS_MSG_RESET|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_INDICATE	cpu_to_le32(0x00000007)
> -#define RNDIS_MSG_KEEPALIVE	cpu_to_le32(0x00000008)
> +#define RNDIS_MSG_INDICATE	0x00000007
> +#define RNDIS_MSG_KEEPALIVE	0x00000008
>  #define RNDIS_MSG_KEEPALIVE_C	(RNDIS_MSG_KEEPALIVE|RNDIS_MSG_COMPLETION)
>
>  /* codes for "status" field of completion messages */
> -#define	RNDIS_STATUS_SUCCESS			cpu_to_le32(0x00000000)
> -#define	RNDIS_STATUS_FAILURE			cpu_to_le32(0xc0000001)
> -#define	RNDIS_STATUS_INVALID_DATA		cpu_to_le32(0xc0010015)
> -#define	RNDIS_STATUS_NOT_SUPPORTED		cpu_to_le32(0xc00000bb)
> -#define	RNDIS_STATUS_MEDIA_CONNECT		cpu_to_le32(0x4001000b)
> -#define	RNDIS_STATUS_MEDIA_DISCONNECT		cpu_to_le32(0x4001000c)
> -#define	RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION	cpu_to_le32(0x40010012)
> +#define	RNDIS_STATUS_SUCCESS			0x00000000
> +#define	RNDIS_STATUS_FAILURE			0xc0000001
> +#define	RNDIS_STATUS_INVALID_DATA		0xc0010015
> +#define	RNDIS_STATUS_NOT_SUPPORTED		0xc00000bb
> +#define	RNDIS_STATUS_MEDIA_CONNECT		0x4001000b
> +#define	RNDIS_STATUS_MEDIA_DISCONNECT		0x4001000c
> +#define	RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION	0x40010012
>
>  /* codes for OID_GEN_PHYSICAL_MEDIUM */
> -#define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	cpu_to_le32(0x00000000)
> -#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	cpu_to_le32(0x00000001)
> -#define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	cpu_to_le32(0x00000002)
> -#define	RNDIS_PHYSICAL_MEDIUM_PHONE_LINE	cpu_to_le32(0x00000003)
> -#define	RNDIS_PHYSICAL_MEDIUM_POWER_LINE	cpu_to_le32(0x00000004)
> -#define	RNDIS_PHYSICAL_MEDIUM_DSL		cpu_to_le32(0x00000005)
> -#define	RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL	cpu_to_le32(0x00000006)
> -#define	RNDIS_PHYSICAL_MEDIUM_1394		cpu_to_le32(0x00000007)
> -#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	cpu_to_le32(0x00000008)
> -#define	RNDIS_PHYSICAL_MEDIUM_MAX		cpu_to_le32(0x00000009)
> +#define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	0x00000000
> +#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	0x00000001
> +#define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	0x00000002
> +#define	RNDIS_PHYSICAL_MEDIUM_PHONE_LINE	0x00000003
> +#define	RNDIS_PHYSICAL_MEDIUM_POWER_LINE	0x00000004
> +#define	RNDIS_PHYSICAL_MEDIUM_DSL		0x00000005
> +#define	RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL	0x00000006
> +#define	RNDIS_PHYSICAL_MEDIUM_1394		0x00000007
> +#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	0x00000008
> +#define	RNDIS_PHYSICAL_MEDIUM_MAX		0x00000009
>
>  struct rndis_data_hdr {
>  	__le32	msg_type;		/* RNDIS_MSG_PACKET */
> @@ -226,24 +226,24 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
>   * there are gobs more that may optionally be supported.  We'll  
> avoid as much
>   * of that mess as possible.
>   */
> -#define OID_802_3_PERMANENT_ADDRESS	cpu_to_le32(0x01010101)
> -#define OID_GEN_MAXIMUM_FRAME_SIZE	cpu_to_le32(0x00010106)
> -#define OID_GEN_CURRENT_PACKET_FILTER	cpu_to_le32(0x0001010e)
> -#define OID_GEN_PHYSICAL_MEDIUM		cpu_to_le32(0x00010202)
> +#define OID_802_3_PERMANENT_ADDRESS	0x01010101
> +#define OID_GEN_MAXIMUM_FRAME_SIZE	0x00010106
> +#define OID_GEN_CURRENT_PACKET_FILTER	0x0001010e
> +#define OID_GEN_PHYSICAL_MEDIUM		0x00010202
>
>  /* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
> -#define RNDIS_PACKET_TYPE_DIRECTED		cpu_to_le32(0x00000001)
> -#define RNDIS_PACKET_TYPE_MULTICAST		cpu_to_le32(0x00000002)
> -#define RNDIS_PACKET_TYPE_ALL_MULTICAST		cpu_to_le32(0x00000004)
> -#define RNDIS_PACKET_TYPE_BROADCAST		cpu_to_le32(0x00000008)
> -#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	cpu_to_le32(0x00000010)
> -#define RNDIS_PACKET_TYPE_PROMISCUOUS		cpu_to_le32(0x00000020)
> -#define RNDIS_PACKET_TYPE_SMT			cpu_to_le32(0x00000040)
> -#define RNDIS_PACKET_TYPE_ALL_LOCAL		cpu_to_le32(0x00000080)
> -#define RNDIS_PACKET_TYPE_GROUP			cpu_to_le32(0x00001000)
> -#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	cpu_to_le32(0x00002000)
> -#define RNDIS_PACKET_TYPE_FUNCTIONAL		cpu_to_le32(0x00004000)
> -#define RNDIS_PACKET_TYPE_MAC_FRAME		cpu_to_le32(0x00008000)
> +#define RNDIS_PACKET_TYPE_DIRECTED		0x00000001
> +#define RNDIS_PACKET_TYPE_MULTICAST		0x00000002
> +#define RNDIS_PACKET_TYPE_ALL_MULTICAST		0x00000004
> +#define RNDIS_PACKET_TYPE_BROADCAST		0x00000008
> +#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	0x00000010
> +#define RNDIS_PACKET_TYPE_PROMISCUOUS		0x00000020
> +#define RNDIS_PACKET_TYPE_SMT			0x00000040
> +#define RNDIS_PACKET_TYPE_ALL_LOCAL		0x00000080
> +#define RNDIS_PACKET_TYPE_GROUP			0x00001000
> +#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	0x00002000
> +#define RNDIS_PACKET_TYPE_FUNCTIONAL		0x00004000
> +#define RNDIS_PACKET_TYPE_MAC_FRAME		0x00008000
>
>  /* default filter used with RNDIS devices */
>  #define RNDIS_DEFAULT_FILTER ( \
> --
> 1.7.7.6
>
>
>



--=_4f7pu51v4tus
Content-Type: text/x-diff;
 charset=ISO-8859-1;
 name="02-rndis_host-rndis_wlan-missing-cpu_to_le32s.patch"
Content-Disposition: attachment;
 filename="02-rndis_host-rndis_wlan-missing-cpu_to_le32s.patch"
Content-Transfer-Encoding: 7bit

rndis_wlan & rndis_host: missing cpu_to_le32()s

From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
---
 drivers/net/usb/rndis_host.c      |    2 +
 drivers/net/wireless/rndis_wlan.c |   74 +++++++++++++++++++------------------
 2 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 05cad0b..3b7ddfd 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -149,7 +149,7 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 	}
 
 	/* Poll the control channel; the request probably completed immediately */
-	rsp = buf->msg_type | RNDIS_MSG_COMPLETION;
+	rsp = buf->msg_type | cpu_to_le32(RNDIS_MSG_COMPLETION);
 	for (count = 0; count < 10; count++) {
 		memset(buf, 0, CONTROL_BUFFER_SIZE);
 		retval = usb_control_msg(dev->udev,
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index a935012..a686b5d 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1033,7 +1033,7 @@ static int rndis_start_bssid_list_scan(struct usbnet *usbdev)
 
 	/* Note: OID_802_11_BSSID_LIST_SCAN clears internal BSS list. */
 	tmp = cpu_to_le32(1);
-	return rndis_set_oid(usbdev, OID_802_11_BSSID_LIST_SCAN, &tmp,
+	return rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_BSSID_LIST_SCAN), &tmp,
 							sizeof(tmp));
 }
 
@@ -1042,7 +1042,7 @@ static int set_essid(struct usbnet *usbdev, struct ndis_80211_ssid *ssid)
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
 	int ret;
 
-	ret = rndis_set_oid(usbdev, OID_802_11_SSID, ssid, sizeof(*ssid));
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_SSID), ssid, sizeof(*ssid));
 	if (ret < 0) {
 		netdev_warn(usbdev->net, "setting SSID failed (%08X)\n", ret);
 		return ret;
@@ -1059,7 +1059,7 @@ static int set_bssid(struct usbnet *usbdev, const u8 *bssid)
 {
 	int ret;
 
-	ret = rndis_set_oid(usbdev, OID_802_11_BSSID, bssid, ETH_ALEN);
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_BSSID), bssid, ETH_ALEN);
 	if (ret < 0) {
 		netdev_warn(usbdev->net, "setting BSSID[%pM] failed (%08X)\n",
 			    bssid, ret);
@@ -1083,7 +1083,7 @@ static int get_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
 	int ret, len;
 
 	len = ETH_ALEN;
-	ret = rndis_query_oid(usbdev, OID_802_11_BSSID, bssid, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_BSSID), bssid, &len);
 
 	if (ret != 0)
 		memset(bssid, 0, ETH_ALEN);
@@ -1094,7 +1094,7 @@ static int get_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
 static int get_association_info(struct usbnet *usbdev,
 			struct ndis_80211_assoc_info *info, int len)
 {
-	return rndis_query_oid(usbdev, OID_802_11_ASSOCIATION_INFORMATION,
+	return rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_ASSOCIATION_INFORMATION),
 				info, &len);
 }
 
@@ -1119,7 +1119,7 @@ static int disassociate(struct usbnet *usbdev, bool reset_ssid)
 	int i, ret = 0;
 
 	if (priv->radio_on) {
-		ret = rndis_set_oid(usbdev, OID_802_11_DISASSOCIATE, NULL, 0);
+		ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_DISASSOCIATE), NULL, 0);
 		if (ret == 0) {
 			priv->radio_on = false;
 			netdev_dbg(usbdev->net, "%s(): radio_on = false\n",
@@ -1181,7 +1181,7 @@ static int set_auth_mode(struct usbnet *usbdev, u32 wpa_version,
 		return -ENOTSUPP;
 
 	tmp = cpu_to_le32(auth_mode);
-	ret = rndis_set_oid(usbdev, OID_802_11_AUTHENTICATION_MODE, &tmp,
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_AUTHENTICATION_MODE), &tmp,
 								sizeof(tmp));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "setting auth mode failed (%08X)\n",
@@ -1208,7 +1208,7 @@ static int set_priv_filter(struct usbnet *usbdev)
 	else
 		tmp = cpu_to_le32(NDIS_80211_PRIV_ACCEPT_ALL);
 
-	return rndis_set_oid(usbdev, OID_802_11_PRIVACY_FILTER, &tmp,
+	return rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_PRIVACY_FILTER), &tmp,
 								sizeof(tmp));
 }
 
@@ -1234,7 +1234,7 @@ static int set_encr_mode(struct usbnet *usbdev, int pairwise, int groupwise)
 		encr_mode = NDIS_80211_ENCR_DISABLED;
 
 	tmp = cpu_to_le32(encr_mode);
-	ret = rndis_set_oid(usbdev, OID_802_11_ENCRYPTION_STATUS, &tmp,
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_ENCRYPTION_STATUS), &tmp,
 								sizeof(tmp));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "setting encr mode failed (%08X)\n",
@@ -1255,7 +1255,7 @@ static int set_infra_mode(struct usbnet *usbdev, int mode)
 		   __func__, priv->infra_mode);
 
 	tmp = cpu_to_le32(mode);
-	ret = rndis_set_oid(usbdev, OID_802_11_INFRASTRUCTURE_MODE, &tmp,
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_INFRASTRUCTURE_MODE), &tmp,
 								sizeof(tmp));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "setting infra mode failed (%08X)\n",
@@ -1282,7 +1282,7 @@ static int set_rts_threshold(struct usbnet *usbdev, u32 rts_threshold)
 		rts_threshold = 2347;
 
 	tmp = cpu_to_le32(rts_threshold);
-	return rndis_set_oid(usbdev, OID_802_11_RTS_THRESHOLD, &tmp,
+	return rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_RTS_THRESHOLD), &tmp,
 								sizeof(tmp));
 }
 
@@ -1296,7 +1296,7 @@ static int set_frag_threshold(struct usbnet *usbdev, u32 frag_threshold)
 		frag_threshold = 2346;
 
 	tmp = cpu_to_le32(frag_threshold);
-	return rndis_set_oid(usbdev, OID_802_11_FRAGMENTATION_THRESHOLD, &tmp,
+	return rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_FRAGMENTATION_THRESHOLD), &tmp,
 								sizeof(tmp));
 }
 
@@ -1333,7 +1333,7 @@ static int set_channel(struct usbnet *usbdev, int channel)
 	dsconfig = ieee80211_dsss_chan_to_freq(channel) * 1000;
 
 	len = sizeof(config);
-	ret = rndis_query_oid(usbdev, OID_802_11_CONFIGURATION, &config, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_CONFIGURATION), &config, &len);
 	if (ret < 0) {
 		netdev_dbg(usbdev->net, "%s(): querying configuration failed\n",
 			   __func__);
@@ -1341,7 +1341,7 @@ static int set_channel(struct usbnet *usbdev, int channel)
 	}
 
 	config.ds_config = cpu_to_le32(dsconfig);
-	ret = rndis_set_oid(usbdev, OID_802_11_CONFIGURATION, &config,
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_CONFIGURATION), &config,
 								sizeof(config));
 
 	netdev_dbg(usbdev->net, "%s(): %d -> %d\n", __func__, channel, ret);
@@ -1359,7 +1359,7 @@ static struct ieee80211_channel *get_current_channel(struct usbnet *usbdev,
 
 	/* Get channel and beacon interval */
 	len = sizeof(config);
-	ret = rndis_query_oid(usbdev, OID_802_11_CONFIGURATION, &config, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_CONFIGURATION), &config, &len);
 	netdev_dbg(usbdev->net, "%s(): OID_802_11_CONFIGURATION -> %d\n",
 				__func__, ret);
 	if (ret < 0)
@@ -1413,7 +1413,7 @@ static int add_wep_key(struct usbnet *usbdev, const u8 *key, int key_len,
 				    ret);
 	}
 
-	ret = rndis_set_oid(usbdev, OID_802_11_ADD_WEP, &ndis_key,
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_ADD_WEP), &ndis_key,
 							sizeof(ndis_key));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "adding encryption key %d failed (%08X)\n",
@@ -1504,7 +1504,7 @@ static int add_wpa_key(struct usbnet *usbdev, const u8 *key, int key_len,
 			get_bssid(usbdev, ndis_key.bssid);
 	}
 
-	ret = rndis_set_oid(usbdev, OID_802_11_ADD_KEY, &ndis_key,
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_ADD_KEY), &ndis_key,
 					le32_to_cpu(ndis_key.size));
 	netdev_dbg(usbdev->net, "%s(): OID_802_11_ADD_KEY -> %08X\n",
 		   __func__, ret);
@@ -1594,13 +1594,13 @@ static int remove_key(struct usbnet *usbdev, u8 index, const u8 *bssid)
 			memset(remove_key.bssid, 0xff,
 						sizeof(remove_key.bssid));
 
-		ret = rndis_set_oid(usbdev, OID_802_11_REMOVE_KEY, &remove_key,
+		ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_REMOVE_KEY), &remove_key,
 							sizeof(remove_key));
 		if (ret != 0)
 			return ret;
 	} else {
 		keyindex = cpu_to_le32(index);
-		ret = rndis_set_oid(usbdev, OID_802_11_REMOVE_WEP, &keyindex,
+		ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_REMOVE_WEP), &keyindex,
 							sizeof(keyindex));
 		if (ret != 0) {
 			netdev_warn(usbdev->net,
@@ -1669,7 +1669,7 @@ static void set_multicast_list(struct usbnet *usbdev)
 		goto set_filter;
 
 	if (mc_count) {
-		ret = rndis_set_oid(usbdev, OID_802_3_MULTICAST_LIST, mc_addrs,
+		ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_3_MULTICAST_LIST), mc_addrs,
 				    mc_count * ETH_ALEN);
 		kfree(mc_addrs);
 		if (ret == 0)
@@ -1682,7 +1682,7 @@ static void set_multicast_list(struct usbnet *usbdev)
 	}
 
 set_filter:
-	ret = rndis_set_oid(usbdev, OID_GEN_CURRENT_PACKET_FILTER, &filter,
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER), &filter,
 							sizeof(filter));
 	if (ret < 0) {
 		netdev_warn(usbdev->net, "couldn't set packet filter: %08x\n",
@@ -1748,7 +1748,7 @@ static struct ndis_80211_pmkid *get_device_pmkids(struct usbnet *usbdev)
 	pmkids->length = cpu_to_le32(len);
 	pmkids->bssid_info_count = cpu_to_le32(max_pmkids);
 
-	ret = rndis_query_oid(usbdev, OID_802_11_PMKID, pmkids, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_PMKID), pmkids, &len);
 	if (ret < 0) {
 		netdev_dbg(usbdev->net, "%s(): OID_802_11_PMKID(%d, %d)"
 				" -> %d\n", __func__, len, max_pmkids, ret);
@@ -1776,7 +1776,7 @@ static int set_device_pmkids(struct usbnet *usbdev,
 
 	debug_print_pmkids(usbdev, pmkids, __func__);
 
-	ret = rndis_set_oid(usbdev, OID_802_11_PMKID, pmkids,
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_PMKID), pmkids,
 						le32_to_cpu(pmkids->length));
 	if (ret < 0) {
 		netdev_dbg(usbdev->net, "%s(): OID_802_11_PMKID(%d, %d) -> %d"
@@ -2113,7 +2113,7 @@ resize_buf:
 	 * resizing until it won't get any bigger.
 	 */
 	new_len = len;
-	ret = rndis_query_oid(usbdev, OID_802_11_BSSID_LIST, buf, &new_len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_BSSID_LIST), buf, &new_len);
 	if (ret != 0 || new_len < sizeof(struct ndis_80211_bssid_list_ex))
 		goto out;
 
@@ -2511,14 +2511,14 @@ static void rndis_fill_station_info(struct usbnet *usbdev,
 	memset(sinfo, 0, sizeof(*sinfo));
 
 	len = sizeof(linkspeed);
-	ret = rndis_query_oid(usbdev, OID_GEN_LINK_SPEED, &linkspeed, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_GEN_LINK_SPEED), &linkspeed, &len);
 	if (ret == 0) {
 		sinfo->txrate.legacy = le32_to_cpu(linkspeed) / 1000;
 		sinfo->filled |= STATION_INFO_TX_BITRATE;
 	}
 
 	len = sizeof(rssi);
-	ret = rndis_query_oid(usbdev, OID_802_11_RSSI, &rssi, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_RSSI), &rssi, &len);
 	if (ret == 0) {
 		sinfo->signal = level_to_qual(le32_to_cpu(rssi));
 		sinfo->filled |= STATION_INFO_SIGNAL;
@@ -2624,7 +2624,7 @@ static int rndis_flush_pmksa(struct wiphy *wiphy, struct net_device *netdev)
 	pmkid.length = cpu_to_le32(sizeof(pmkid));
 	pmkid.bssid_info_count = cpu_to_le32(0);
 
-	return rndis_set_oid(usbdev, OID_802_11_PMKID, &pmkid, sizeof(pmkid));
+	return rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_PMKID), &pmkid, sizeof(pmkid));
 }
 
 static int rndis_set_power_mgmt(struct wiphy *wiphy, struct net_device *dev,
@@ -2654,7 +2654,7 @@ static int rndis_set_power_mgmt(struct wiphy *wiphy, struct net_device *dev,
 	priv->power_mode = power_mode;
 
 	mode = cpu_to_le32(power_mode);
-	ret = rndis_set_oid(usbdev, OID_802_11_POWER_MODE, &mode, sizeof(mode));
+	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_POWER_MODE), &mode, sizeof(mode));
 
 	netdev_dbg(usbdev->net, "%s(): OID_802_11_POWER_MODE -> %d\n",
 				__func__, ret);
@@ -2693,7 +2693,7 @@ static void rndis_wlan_craft_connected_bss(struct usbnet *usbdev, u8 *bssid,
 	/* Get signal quality, in case of error use rssi=0 and ignore error. */
 	len = sizeof(rssi);
 	rssi = 0;
-	ret = rndis_query_oid(usbdev, OID_802_11_RSSI, &rssi, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_RSSI), &rssi, &len);
 	signal = level_to_qual(le32_to_cpu(rssi));
 
 	netdev_dbg(usbdev->net, "%s(): OID_802_11_RSSI -> %d, "
@@ -2720,7 +2720,7 @@ static void rndis_wlan_craft_connected_bss(struct usbnet *usbdev, u8 *bssid,
 	/* Get SSID, in case of error, use zero length SSID and ignore error. */
 	len = sizeof(ssid);
 	memset(&ssid, 0, sizeof(ssid));
-	ret = rndis_query_oid(usbdev, OID_802_11_SSID, &ssid, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_SSID), &ssid, &len);
 	netdev_dbg(usbdev->net, "%s(): OID_802_11_SSID -> %d, len: %d, ssid: "
 				"'%.32s'\n", __func__, ret,
 				le32_to_cpu(ssid.length), ssid.essid);
@@ -3097,7 +3097,7 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 
 	switch (msg->status) {
 	case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNECT):
-		if (priv->current_command_oid == OID_802_11_ADD_KEY) {
+		if (priv->current_command_oid == cpu_to_le32(OID_802_11_ADD_KEY)) {
 			/* OID_802_11_ADD_KEY causes sometimes extra
 			 * "media connect" indications which confuses driver
 			 * and userspace to think that device is
@@ -3148,7 +3148,7 @@ static int rndis_wlan_get_caps(struct usbnet *usbdev, struct wiphy *wiphy)
 
 	/* determine supported modes */
 	len = sizeof(networks_supported);
-	retval = rndis_query_oid(usbdev, OID_802_11_NETWORK_TYPES_SUPPORTED,
+	retval = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_NETWORK_TYPES_SUPPORTED),
 						&networks_supported, &len);
 	if (retval >= 0) {
 		n = le32_to_cpu(networks_supported.num_items);
@@ -3173,7 +3173,7 @@ static int rndis_wlan_get_caps(struct usbnet *usbdev, struct wiphy *wiphy)
 	/* get device 802.11 capabilities, number of PMKIDs */
 	caps = (struct ndis_80211_capability *)caps_buf;
 	len = sizeof(caps_buf);
-	retval = rndis_query_oid(usbdev, OID_802_11_CAPABILITY, caps, &len);
+	retval = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_CAPABILITY), caps, &len);
 	if (retval >= 0) {
 		netdev_dbg(usbdev->net, "OID_802_11_CAPABILITY -> len %d, "
 				"ver %d, pmkids %d, auth-encr-pairs %d\n",
@@ -3247,7 +3247,7 @@ static void rndis_device_poller(struct work_struct *work)
 	}
 
 	len = sizeof(rssi);
-	ret = rndis_query_oid(usbdev, OID_802_11_RSSI, &rssi, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_RSSI), &rssi, &len);
 	if (ret == 0) {
 		priv->last_qual = level_to_qual(le32_to_cpu(rssi));
 		rndis_do_cqm(usbdev, le32_to_cpu(rssi));
@@ -3275,7 +3275,7 @@ static void rndis_device_poller(struct work_struct *work)
 		 * working.
 		 */
 		tmp = cpu_to_le32(1);
-		rndis_set_oid(usbdev, OID_802_11_BSSID_LIST_SCAN, &tmp,
+		rndis_set_oid(usbdev, cpu_to_le32(OID_802_11_BSSID_LIST_SCAN), &tmp,
 								sizeof(tmp));
 
 		len = CONTROL_BUFFER_SIZE;
@@ -3283,7 +3283,7 @@ static void rndis_device_poller(struct work_struct *work)
 		if (!buf)
 			goto end;
 
-		rndis_query_oid(usbdev, OID_802_11_BSSID_LIST, buf, &len);
+		rndis_query_oid(usbdev, cpu_to_le32(OID_802_11_BSSID_LIST), buf, &len);
 		kfree(buf);
 	}
 
@@ -3603,7 +3603,7 @@ static int rndis_wlan_stop(struct usbnet *usbdev)
 	/* Set current packet filter zero to block receiving data packets from
 	   device. */
 	filter = 0;
-	rndis_set_oid(usbdev, OID_GEN_CURRENT_PACKET_FILTER, &filter,
+	rndis_set_oid(usbdev, cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER), &filter,
 								sizeof(filter));
 
 	return retval;

--=_4f7pu51v4tus--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
