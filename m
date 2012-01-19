From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH 2/3 V3.1] can/usb: PEAK-System Technik PCAN-USB specific
 part
Date: Thu, 19 Jan 2012 10:07:45 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1201191004540.1447-100000@iolanthe.rowland.org>
References: <1326968863-20229-3-git-send-email-s.grosjean@peak-system.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	linux-usb Mailing List <linux-usb@vger.kernel.org>,
	netdev Mailing List <netdev@vger.kernel.org>,
	linux-can Mailing List <linux-can@vger.kernel.org>
To: Stephane Grosjean <s.grosjean@peak-system.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1326968863-20229-3-git-send-email-s.grosjean@peak-system.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jan 2012, Stephane Grosjean wrote:

> This patch adds the specific part which handles the PCAN-USB adapter from
> PEAK-System Technik (http://www.peak-system.com). The PCAN-USB adapter is
> a sja1000 based, mono-channel USB 1.1 adapter compliant with CAN
> specifications 2.0A (11-bit ID) and 2.0B (29-bit ID).
> 
> V3.1: same as V3 + add linux-can in cc:
> +/*
> + * send a command
> + */
> +static int pcan_usb_send_cmd(struct peak_usb_device *dev, u8 f, u8 n, u8 *p)
> +{
> +	int err;
> +	int actual_length;
> +	struct pcan_usb_parameter cmd = {
> +		.function = f,
> +		.number = n,
> +	};
> +
> +	/* usb device unregistered? */
> +	if (!(dev->state & PCAN_USB_STATE_CONNECTED))
> +		return 0;
> +
> +	if (p)
> +		memcpy(cmd.parameters, p, ARRAY_SIZE(cmd.parameters));
> +
> +	err = usb_bulk_msg(dev->udev,
> +		usb_sndbulkpipe(dev->udev, PCAN_USB_EP_CMDOUT), &cmd,
> +		sizeof(struct pcan_usb_parameter), &actual_length,
> +		PCAN_USB_COMMAND_TIMEOUT);

Here, and in several other places in this patch series, you submit
requests using a transfer buffer that is allocated on the stack.  This
is forbidden because not all platforms can do DMA to stack or static
addresses.  The transfer buffers should be allocated dynamically.

Alan Stern

