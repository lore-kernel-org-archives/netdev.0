From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v5 4/5] can: kvaser_usb: Retry the first bulk transfer on
 -ETIMEDOUT
Date: Sun, 25 Jan 2015 13:59:19 +0200
Message-ID: <20150125115919.GA16000@Darwish.PC>
References: <20141223154654.GB6460@vivalin-002>
 <20150120214409.GA16828@linux>
 <20150120214537.GB16828@linux>
 <20150120214709.GC16828@linux>
 <20150120214834.GD16828@linux>
 <54BF9A8E.7000202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andri Yngvason <andri.yngvason@marel.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54BF9A8E.7000202@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 21, 2015 at 03:24:46PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 1/21/2015 12:48 AM, Ahmed S. Darwish wrote:
> 
> >From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> 
> >On some x86 laptops, plugging a Kvaser device again after an
> >unplug makes the firmware always ignore the very first command.
> >For such a case, provide some room for retries instead of
> >completly exiting the driver init code.
> 
>    Completely.
> 
> >Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> >---
> >  drivers/net/can/usb/kvaser_usb.c | 12 ++++++++++--
> >  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> >diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
> >index 640b0eb..068e76c 100644
> >--- a/drivers/net/can/usb/kvaser_usb.c
> >+++ b/drivers/net/can/usb/kvaser_usb.c
> [...]
> >@@ -1632,7 +1632,15 @@ static int kvaser_usb_probe(struct usb_interface *intf,
> >
> >  	usb_set_intfdata(intf, dev);
> >
> >-	err = kvaser_usb_get_software_info(dev);
> >+	/* On some x86 laptops, plugging a Kvaser device again after
> >+	 * an unplug makes the firmware always ignore the very first
> >+	 * command. For such a case, provide some room for retries
> >+	 * instead of completly exiting the driver.
> 
>    Completely.
> 

Thanks, both fixed in the next submission :-D

Regards,
Darwish
