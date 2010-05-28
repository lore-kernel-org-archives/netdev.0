From: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Subject: Re: [PATCH v3] can: Add driver for esd CAN-USB/2 device
Date: Fri, 28 May 2010 17:25:31 +0200
Message-ID: <201005281725.32049.matthias.fuchs@esd.eu>
References: <201005261114.03214.matthias.fuchs@esd.eu>
	<70376CA23424B34D86F1C7DE6B9973430254343AD9@VSHINMSMBX01.vshodc.lntinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Viral Mehta <Viral.Mehta-oonXi/34qI7c+919tysfdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <70376CA23424B34D86F1C7DE6B9973430254343AD9-fVvhrSDAkVjuuPCCJ6VnObSn4PsL5ZDKvpI+GvaZM4lBDgjK7y7TUQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Viral,

thanks for review. Please see some comments below.

On Wednesday 26 May 2010 13:31, Viral Mehta wrote:
> Hi,
> >________________________________________
> >From: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Matthias Fuchs [matthias.fuchs-iOnpLzIbIdM@public.gmane.org]
> >Sent: Wednesday, May 26, 2010 2:44 PM
> >To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >Subject: [PATCH v3] can: Add driver for esd CAN-USB/2 device
> >+
> >+       BUG_ON(!context);
> 
> It is preferred to used WARN_ON and avoid using BUG_ON and thus dont kill the whole system....
Really? Even when next line will reference a NULL pointer in this case? Ok. Will be changed.

> [...]
> >+
> >+       priv = context->priv;
> >+       netdev = priv->netdev;
> >+       dev = priv->usb2;
> >+       err = usb_submit_urb(urb, GFP_ATOMIC);
> >+       if (err) {
> >+               can_free_echo_skb(netdev, context->echo_index);
> >+
> >+               atomic_dec(&priv->active_tx_jobs);
> >+               usb_unanchor_urb(urb);
> >+
> >+               stats->tx_dropped++;
> >+
> >+               if (err == -ENODEV)
> >+                       netif_device_detach(netdev);
> >+               else
> >+                       dev_warn(netdev->dev.parent, "failed tx_urb %d\n", err);
> >+
> >+               goto releasebuf;
> 
> You probably want to set "ret" here or do you really want to return NETDEV_TX_OK
As far as I can see netword device drivers xmit_start() return NETDEV_TX_OK or _BUSY.
There are no real alternatives. But please correct me when I am wrong.

Your other comments will be fixed by version 4 of my patch.

Matthias
