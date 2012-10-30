From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
Date: Tue, 30 Oct 2012 17:30:13 +0100
Message-ID: <2504263.kbM6W9JoH9@linux-lqwf.site>
References: <CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com> <Pine.LNX.4.44L0.1210301112270.1363-100000@iolanthe.rowland.org> <CACVXFVO5-UPNrWsySzDE5AfOv1TMqbyitQX9ViidSJPM36fqAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-pm@vger.kernel.org, linux-mm@kvack.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <CACVXFVO5-UPNrWsySzDE5AfOv1TMqbyitQX9ViidSJPM36fqAQ@mail.gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 31 October 2012 00:00:56 Ming Lei wrote:
> On Tue, Oct 30, 2012 at 11:38 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
> 
> >
> > Okay, I see your point.  But acquiring the lock here doesn't solve the
> > problem.  Suppose a thread is about to reset a USB mass-storage device.
> > It acquires the lock and sees that the noio flag is clear.  But before
> > it can issue the reset, another thread sets the noio flag.
> 
> If the USB mass-storage device is being reseted, the flag should be set
> already generally.  If the flag is still unset, that means the disk/network
> device isn't added into system(or removed just now), so memory allocation
> with block I/O should be allowed during the reset. Looks it isn't one problem,
> isn't it?

I am afraid it is, because a disk may just have been probed as the deviceis being reset.

	Regards
		Oliver

