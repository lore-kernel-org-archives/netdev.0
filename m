From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH v2 7/7] driver-core: add preferred async probe option for
 built-in and modules
Date: Mon, 6 Oct 2014 13:41:55 -0700
Message-ID: <20141006204155.GA37994@dtor-ws>
References: <1412372683-2003-1-git-send-email-mcgrof@do-not-panic.com>
 <1412372683-2003-8-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, tiwai@suse.de, tj@kernel.org,
	arjan@linux.intel.com, teg@jklm.no, rmilasan@suse.com,
	werner@suse.com, oleg@redhat.com, hare@suse.com, bpoirier@suse.de,
	santosh@chelsio.com, pmladek@suse.cz, dbueso@suse.com,
	mcgrof@suse.com, linux-kernel@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsi
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412372683-2003-8-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Luis,

On Fri, Oct 03, 2014 at 02:44:43PM -0700, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> At times we may wish to express the desire to prefer to have
> a device driver probe asynchronously by default. We cannot
> simply enable all device drivers to do this without vetting
> that userspace is prepared for this though given that some
> old userspace is expected to exist which is not equipped to
> deal with broad async probe support. This defines a new kernel
> parameter, bus.enable_kern_async=1, to help address this both to
> help enable async probe support for built-in drivers and to
> enable drivers to specify a preference to opt in for async
> probe support.
> 
> If you have a device driver that should use async probe
> support when possible enable the prefer_async_probe bool.
> 
> Folks wishing to test enabling async probe for all built-in
> drivers can enable bus.__DEBUG__kernel_force_mod_async_probe=1,
> if you use that though you are on your own.

Thank you for working on this. However there are still couple of issues
with the async probe.

1. As far as I can see you only handle the case when device is already
present and you load a driver. In this case we will do either async or
sync probing, depending on the driver/module settings. However if driver
has already been loaded/registered and we are adding a new device
(another module load, for example you load i2c controller module and it
enumerates its children, or driver signalled deferral during binding)
the probe will be synchronous regardless of the settings.

2. I thin kin the current implementation deferred binding process is
still single-threaded and basically synchronous.

Both of these issues stem form the fact that you only plugging into
bus_add_driver(), but you also need to plug into bus_probe_device(). I
believe I handled these 2 cases properly in the version of patch I sent
a couple of weeks ago so if you could incorporate that in your work that
would be great.

Thanks.

-- 
Dmitry
