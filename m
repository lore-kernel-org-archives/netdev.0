From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v4 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
Date: Wed, 7 Nov 2012 11:32:04 +0800
Message-ID: <CACVXFVNjffkKWEdboPLuL8CpeUm4H8eDPfL5X4ePVPXL2xFR8w@mail.gmail.com>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<1351931714-11689-3-git-send-email-ming.lei@canonical.com>
	<20121106152419.9155a366.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>,
	Minchan Kim <minchan@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20121106152419.9155a366.akpm@linux-foundation.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 7, 2012 at 7:24 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> checkpatch finds a number of problems with this patch, all of which
> should be fixed.  Please always use checkpatch.

Sorry for missing the check.

>> +             /* only clear the flag for one device if all
>> +              * children of the device don't set the flag.
>> +              */
>
> Such a comment is usually laid out as
>
>                 /*
>                  * Only ...

Will do it in -v5.

> More significantly, the comment describes what the code is doing but
> not why the code is doing it.  The former is (usually) obvious from
> reading the C, and the latter is what good code comments address.
>
> And it's needed in this case.  Why does the code do this?

Suppose both two usb scsi disks which share the same usb
configuration(device) set the device memalloc_noio flag, and
its ancestors' memalloc_noio flag should be cleared only after
both the two usb scsi disk's flags have been cleared.

OK, we'll add comment on clearing flag.

>
> Also, can a device have more than one child?  If so, the code doesn't
> do what the comment says it does.

It should do that because device_for_each_child() returns true immediately
only if dev_memalloc_noio() for one child returns true.

>
>> +             if (!dev || (!enable &&
>> +                          device_for_each_child(dev, NULL,
>> +                                                dev_memalloc_noio)))
>> +                     break;
>> +     }
>> +     mutex_unlock(&dev_hotplug_mutex);
>> +}
>> +EXPORT_SYMBOL_GPL(pm_runtime_set_memalloc_noio);


Thanks,
--
Ming Lei
