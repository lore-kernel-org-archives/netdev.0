From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [PATCH 1/5] initdev:kernel: Asynchronously-discovered device
	synchronization, v5
Date: Sat, 02 May 2009 09:01:16 -0500
Message-ID: <1241272876.3639.27.camel@mulgrave.int.hansenpartnership.com>
References: <20090502022551.GA15600@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090502022551.GA15600-CFZJ1or75eBPWxJt6d6B6bQa8qPdvLwY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-05-01 at 19:25 -0700, David VomLehn wrote:
> +Init Device Discovery Synchronization
> +=====================================
> +Init devices are those devices that must be used or configured before
> +starting up the /bin/init process.  They may be explicitly specified as
> +kernel command line parameters, such as console=ttyUSB0,115200, or
> +implicitly specified, such as ip=dhcp.
> +
> +Earlier versions of the Linux kernel used a single-threaded approach to
> +boot initialization. This took a number of seconds, which meant that
> +devices were generally set up before being used or configured. Modern
> +kernels use a multithreaded approach, which requires synchronization between
> +code that probes and initializes init devices, and code that uses and
> +configures them.  Support of fine-grained boot concurrency requires
> +distinguishing between types of init devices, so that devices can be used as
> +soon as they are initialized.
> +
> +There are several types of init devices:
> +-	consoles
> +-	network devices
> +-	block devices

OK, so in your scheme, I get why console devices: they need to be
present early before we start dumping console output otherwise it can
get lost.

However, I don't see the need for either network or block.

For network, the only early discovery use is net root (which can be done
fully asynchronously) or net console (which I think can be supplied a
raft of information and isn't usually expected to be up by early boot
because of the TCP stack dependence) neither of which is a compelling
use case.

Block, likewise, is a udev type discovery:  We can specify the root by
some type of ID and we can wait until that is found, rather than have an
elaborate system to check when discovery is finished, which is the only
benefit this code seems to provide.

What I'm getting at is that I don't see the benefit of this in the light
of Arjan's async boot system, which can also tell us when all discovery
is complete ... what added benefit am I missing here?

James


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
