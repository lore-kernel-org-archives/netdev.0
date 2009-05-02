From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/5] initdev:kernel: USB and SCSI block init device
 notification, v3
Date: Sat, 2 May 2009 11:55:39 +0800
Message-ID: <20090502115539.396206bc@linux-lm>
References: <20090502023000.GA16076@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090502023000.GA16076-CFZJ1or75eBPWxJt6d6B6bQa8qPdvLwY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 1 May 2009 19:30:00 -0700
David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org> wrote:

> From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org
> 
> Add notification of device discovery for USB and SCSI block devices.
> 
> History
> v3	Change bootdev_* to initdev_*
> v2	Correct location of call to bootdev_found
> v1	Initial version
> 
> Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org
> Signed-off-by: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/scsi/scsi_scan.c  |    2 ++
>  drivers/usb/storage/usb.c |    3 +++
>  2 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/scsi/scsi_scan.c b/drivers/scsi/scsi_scan.c
> index 6f51ca4..735b061 100644
> --- a/drivers/scsi/scsi_scan.c
> +++ b/drivers/scsi/scsi_scan.c
> @@ -1834,6 +1834,7 @@ static int do_scan_async(void *_data)
>  	struct async_scan_data *data = _data;
>  	do_scsi_scan_host(data->shost);
>  	scsi_finish_async_scan(data);
> +	initdev_probe_done(BOOTDEV_BLOCK_MASK);

Which code are waiting for the block device's probe done?


>  	return 0;
>  }
>  
> @@ -1855,6 +1856,7 @@ void scsi_scan_host(struct Scsi_Host *shost)
>  		return;
>  	}
>  
> +	initdev_found(BOOTDEV_BLOCK_MASK);
>  	p = kthread_run(do_scan_async, data, "scsi_scan_%d",
> shost->host_no); if (IS_ERR(p))
>  		do_scan_async(data);
> diff --git a/drivers/usb/storage/usb.c b/drivers/usb/storage/usb.c
> index 8060b85..ea7abab 100644
> --- a/drivers/usb/storage/usb.c
> +++ b/drivers/usb/storage/usb.c
> @@ -837,6 +837,7 @@ static int usb_stor_scan_thread(void * __us)
>  		/* Should we unbind if no devices were detected? */
>  	}
>  
> +	initdev_probe_done(BOOTDEV_BLOCK_MASK);

the same question with above.

>  	complete_and_exit(&us->scanning_done, 0);
>  }
>  
> @@ -937,10 +938,12 @@ int usb_stor_probe2(struct us_data *us)
>  	}
>  
>  	/* Start up the thread for delayed SCSI-device scanning */
> +	initdev_found(BOOTDEV_BLOCK_MASK);
>  	th = kthread_create(usb_stor_scan_thread, us,
> "usb-stor-scan"); if (IS_ERR(th)) {
>  		printk(KERN_WARNING USB_STORAGE 
>  		       "Unable to start the device-scanning
> thread\n");
> +		initdev_probe_done(BOOTDEV_BLOCK_MASK);

the same question with above.

>  		complete(&us->scanning_done);
>  		quiesce_and_remove_host(us);
>  		result = PTR_ERR(th);
> --


-- 
Lei Ming
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
