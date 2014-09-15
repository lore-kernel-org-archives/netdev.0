From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: can: usb: peak_usb: pcan_usb_core.c:  Cleaning up
 missing null-terminate in conjunction with strncpy
Date: Mon, 15 Sep 2014 08:28:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17491F2B@AcuExch.aculab.com>
References: <1410715898-15904-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"Christopher R. Baker" <cbaker@rec.ri.cmu.edu>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Rickard Strandqvist' <rickard_strandqvist@spectrumdigital.se>,
	"Wolfgang Grandegger" <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410715898-15904-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist
...
> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
...
> diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> index 644e6ab..d4fe8ac 100644
> --- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> +++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> @@ -830,7 +830,7 @@ static void peak_usb_disconnect(struct usb_interface *intf)
>  		char name[IFNAMSIZ];
> 
>  		dev->state &= ~PCAN_USB_STATE_CONNECTED;
> -		strncpy(name, netdev->name, IFNAMSIZ);
> +		strlcpy(name, netdev->name, IFNAMSIZ);
> 
>  		unregister_netdev(netdev);
>  		free_candev(netdev);

Or:
	char name[sizeof netdev->name];
	memcpy(name, netdev->name, sizeof netdev->name);

	David
