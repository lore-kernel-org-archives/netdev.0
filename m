From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
Date: Wed, 31 Oct 2012 11:41:07 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1210311139300.1954-100000@iolanthe.rowland.org>
References: <Pine.LNX.4.44L0.1210311117310.1954-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Neukum <oneukum@suse.de>,  <linux-kernel@vger.kernel.org>,
    Minchan Kim <minchan@kernel.org>,
    Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
    "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>,
    "David S. Miller" <davem@davemloft.net>,
    Andrew Morton <akpm@linux-foundation.org>,  <netdev@vger.kernel.org>,
     <linux-usb@vger.kernel.org>,  <linux-pm@vger.kernel.org>,
     <linux-mm@kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <Pine.LNX.4.44L0.1210311117310.1954-100000@iolanthe.rowland.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2012, Alan Stern wrote:

> On Wed, 31 Oct 2012, Ming Lei wrote:
> 
> > The below idea may help the problem which 'memalloc_noio' flag isn't set during
> > usb_reset_device().
> > 
> > - for usb mass storage device, call pm_runtime_set_memalloc_noio(true)
> >   inside usb_stor_probe2() and uas_probe(), and call
> >   pm_runtime_set_memalloc_noio(false) inside uas_disconnect()
> >   and usb_stor_disconnect().
> 
> Why would you want to do that?  The probe and disconnect routines
> usually -- but not always -- run in the khubd thread.  Surely you don't
> want to prevent khubd from using GFP_KERNEL?
> 
> And what if probe runs in khubd but disconnect runs in a different 
> thread?

Sorry, I misread your message.  You are setting the device's flag, not 
the thread's flag.

This still doesn't help in this case where CONFIG_PM_RUNTIME is 
disabled.  I think it will be simpler to set the noio flag during every 
device reset.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
