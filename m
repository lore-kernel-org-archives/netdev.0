From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] Adding Reset resume support for CDC-EEM driver.
Date: Mon, 21 Dec 2015 10:56:04 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1512211053330.22031-100000@netrider.rowland.org>
References: <1450699731-4666-1-git-send-email-vikas.bansal@samsung.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: oneukum@suse.de, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<sumit.batra@samsung.com>
To: Vikas Bansal <vikas.bansal@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450699731-4666-1-git-send-email-vikas.bansal@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Dec 2015, Vikas Bansal wrote:

> Pre-Condition
> At the time of reset resume of a USB device, both self and bus powered devices might go to a low power state or power off state depending on the acceptable suspend time power of the system.    
> In case the device experiences a power glitch or completely powers off during suspend-resume, the device will lose its internal state and hence it'll again need a set interface from class driver on reset resume operation.
> 
> Issue 
> So far our experiments were based on a USB gadget working on cdc_eem protocol. 
> We have seen that device is unable to continue the packet transfer on bulk endpoints after the reset resume operation.
> 
> Solution
> We have added a .reset_resume function for cdc_eem protocol which sends a set interface command on the Control endpoint. And calls the existing usbnet_resume thereafter

You know, the USB core already issues a Set-Interface request on the
control endpoint whenever a reset-resume occurs (unless the interface
was using altsetting 0 beforehand).  Issuing another Set-Interface
shouldn't make any difference.

Alan Stern
