From: Matthias Fuchs <matthias.fuchs@esd.eu>
Subject: Re: [PATCH] net: can: esd_usb2: fix memory leak on disconnect
Date: Mon, 13 Oct 2014 10:05:47 +0200
Message-ID: <543B87DB.8090104@esd.eu>
References: <1412973067-29707-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ldv-project@linuxtesting.org" <ldv-project@linuxtesting.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1412973067-29707-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexey,

On 10/10/2014 10:31 PM, Alexey Khoroshilov wrote:
> It seems struct esd_usb2 dev is not deallocated on disconnect.
> 
> The patch adds the deallocation.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>  drivers/net/can/usb/esd_usb2.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
> index b7c9e8b11460..7a90075529c3 100644
> --- a/drivers/net/can/usb/esd_usb2.c
> +++ b/drivers/net/can/usb/esd_usb2.c
> @@ -1143,6 +1143,7 @@ static void esd_usb2_disconnect(struct usb_interface *intf)
>  			}
>  		}
>  		unlink_all_urbs(dev);
> +		kfree(dev);
>  	}
>  }
>  
> 
thanks for pointing this out. Marc, can you please catch this up.

Matthias

Acked-by: Matthias Fuchs <matthias.fuchs@esd.eu>
