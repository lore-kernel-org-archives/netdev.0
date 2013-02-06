From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/2 v2] sierra_net: fix issues with SYNC/RESTART messages and interrupt pipe setup
Date: Wed, 06 Feb 2013 21:17:16 +0100
Message-ID: <2485224.kk5J89zEMM@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1357318289.5370.19.camel@dcbw.foobar.com> <1360176176.11742.16.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1360176176.11742.16.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 06 February 2013 12:42:56 Dan Williams wrote:
> As part of the initialization sequence, the driver sends a SYNC message
> via the control pipe to the firmware, which appears to request a
> firmware restart.  The firmware responds with an indication via the
> interrupt pipe set up by usbnet.  If the driver does not receive a
> RESTART indication within a certain amount of time, it will periodically
> send additional SYNC messages until it receives the RESTART indication.
> 
> Unfortunately, the interrupt URB is only submitted while the netdev
> is open, which is usually not the case during initialization, and thus
> the firmware's RESTART indication is lost.  So the driver continues
> sending SYNC messages, and eventually the firmware crashes when it
> receives too many.  This leads to a wedged netdev.

If I understand this correctly we should stop the interrupt pipe once
RESTART has been recieved. I am afraid this patch is a bit inefficient.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
