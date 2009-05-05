From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH 5/5] initdev:kernel: USB and SCSI block init device
	notification, v3
Date: Mon, 4 May 2009 17:19:50 -0700
Message-ID: <20090505001950.GC29124@cuplxvomd02.corp.sa.net>
References: <20090502023000.GA16076@cuplxvomd02.corp.sa.net> <20090502115539.396206bc@linux-lm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090502115539.396206bc@linux-lm>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 01, 2009 at 11:55:39PM -0400, Ming Lei wrote:
> On Fri, 1 May 2009 19:30:00 -0700
> David VomLehn <dvomlehn@cisco.com> wrote:
> 
> > From: Alan Stern <stern@rowland.harvard.edu
> > diff --git a/drivers/scsi/scsi_scan.c b/drivers/scsi/scsi_scan.c
> > index 6f51ca4..735b061 100644
> > --- a/drivers/scsi/scsi_scan.c
> > +++ b/drivers/scsi/scsi_scan.c
...
> > @@ -1834,6 +1834,7 @@ static int do_scan_async(void *_data)
> >  	struct async_scan_data *data = _data;
> >  	do_scsi_scan_host(data->shost);
> >  	scsi_finish_async_scan(data);
> > +	initdev_probe_done(BOOTDEV_BLOCK_MASK);
> 
> Which code are waiting for the block device's probe done?

None yet. That remains to be done.

> > diff --git a/drivers/usb/storage/usb.c b/drivers/usb/storage/usb.c
> > index 8060b85..ea7abab 100644
> > --- a/drivers/usb/storage/usb.c
> > +++ b/drivers/usb/storage/usb.c
> > @@ -837,6 +837,7 @@ static int usb_stor_scan_thread(void * __us)
> >  		/* Should we unbind if no devices were detected? */
> >  	}
> >  
> > +	initdev_probe_done(BOOTDEV_BLOCK_MASK);
> 
> the same question with above.

Same answer.

> > @@ -937,10 +938,12 @@ int usb_stor_probe2(struct us_data *us)
> >  	}
> >  
> >  	/* Start up the thread for delayed SCSI-device scanning */
> > +	initdev_found(BOOTDEV_BLOCK_MASK);
> >  	th = kthread_create(usb_stor_scan_thread, us,
> > "usb-stor-scan"); if (IS_ERR(th)) {
> >  		printk(KERN_WARNING USB_STORAGE 
> >  		       "Unable to start the device-scanning
> > thread\n");
> > +		initdev_probe_done(BOOTDEV_BLOCK_MASK);
> 
> the same question with above.

Same answer.

> Lei Ming

Thanks!

David VomLehn
