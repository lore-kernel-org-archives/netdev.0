From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 12:25:58 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B702F@saturn3.aculab.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com><1631246.gHVDWoZpLi@linux-lqwf.site><CACVXFVMq8-t2o5=M=3xCQEiPFXjvH14g3NtRgOTMYr542d5zXw@mail.gmail.com><1691674.ASueyuVmUn@linux-lqwf.site> <CACVXFVPDg89y7LyKLA0YUN7oA2rGfptfHLZhJrqBjTVPjsGdNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Ming Lei" <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"Oliver Neukum" <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <CACVXFVPDg89y7LyKLA0YUN7oA2rGfptfHLZhJrqBjTVPjsGdNg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Wed, Oct 10, 2012 at 6:08 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> 
> > A reset always applies to the whole device. Resets are used in error
> > handling of block devices (storage and uas). If you reset a device,
> > pre_reset() and post_reset() of all interfaces need to be called. So they
> > are part of the SCSI error handler. SCSI error handlers can allocate memory
> > only with GFP_NOIO (or GFP_ATOMIC) because any IO for paging
> > can cause the SCSI layer to wait for the error handling to finish. The error
> > handling can only finish when pre/post_reset() have finished. Catch-22
> 
> IMO, it is not practical to obey the rule for drivers, because driver may
> call many other kernel component API which may allocate memory
> via GFP_KERNEL in the path easily.

What about the error handler/sleep/resume code calling into the
memory allocator to indicate that all allocates be GFP_NOIO until
it calls back to indicate that the restricted path is complete.
Might be a per-cpu count?

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
