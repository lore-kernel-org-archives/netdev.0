From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: SmPL for automatic request_firmware_nowait() conversion
Date: Tue, 24 Jun 2014 23:58:28 +0200
Message-ID: <20140624215828.GA14124@electric-eye.fr.zoreil.com>
References: <20140621015714.GX4841@wotan.suse.de>
 <20140621105205.GA31611@electric-eye.fr.zoreil.com>
 <20140623232107.GB27687@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cocci@systeme.lip6.fr, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140623232107.GB27687@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez <mcgrof@suse.com> :
> On Sat, Jun 21, 2014 at 12:52:05PM +0200, Francois Romieu wrote:
> > Luis R. Rodriguez <mcgrof@suse.com> :
[...]
> Note that in the worst case if udev is present in the worst case if the
> firmware is not present loading can take up to timeout * num CPUs [0],
> but work is underway to try to remove udev firmware loading support [1].
> Regardless then the current approach seemed to beg a rework.
> 
> [0] https://lkml.org/lkml/2013/10/23/264
> [1] http://comments.gmane.org/gmane.comp.sysutils.systemd.devel/19440

Thanks for the pointers.

I can't help thinking that there's a bit of sensationalism in the
timeout * num CPUs argument though. :o)

[...]
> The kernel's timeout is 60 seconds, and this is static, but lets be clear
> that there is a difference between the timeout for reading the firmware
> from the filesystem and actually dumping the firmware onto the device
> by the driver and ensuring that the driver is done poking at it. The
> kernel timeout is for the kernel reading it and tossing it back to the
> driver.

You are right.

[...]
> I was actually in the hopes a suitable transormation can be designed
> to put a wait_for_completion() in say ndo_init(). I was looking to
> see if a tranformation can be generalized of course if the above
> observations on probe() is something desirable to be addressed.

register_netdev is commonly called at the end of the probe method. probe()
would thus schedule an async firmware loading, fly, then wait_for_completion()
through register_netdev->ndo_init(). If so there won't be much gain.

There could be more gain with a wait_for_completion() in ndo_open()
but probe() + ndo_open() would still hit any fw read/poke/complete wall.

It can be done but it will imvho require a lot of driver dependant work.

-- 
Ueimor
