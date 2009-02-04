From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [RFC] Suspicious bug in module refcounting
Date: Wed, 4 Feb 2009 10:11:30 +0000
Message-ID: <20090204101130.GB19498@flint.arm.linux.org.uk>
References: <20090203134721.GA11069@pingi.kke.suse.de> <200902041418.09630.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <kkeil@suse.de>, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@suse.cz>,
	richard kennedy <richard@rsk.demon.co.uk>,
	Dan Williams <dan.j.williams@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	dwmw2@infradead.org, Scott Wood <scottwood@freescale.com>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752305AbZBDKMX@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200902041418.09630.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 04, 2009 at 02:18:08PM +1030, Rusty Russell wrote:
>   gameport.c, serio.c and input.c increment their own refcount, but to get
> into those init functions someone must be holding a refcount already (ie. a
> module depends on this module).  Ditto cyber2000fb.c, and MTD.

Err, wrong.  cyber2000fb.c does it in its module initialization function
to prevent the module (when built for Shark) from being unloaded.  It
does this because it's from the days of 2.2 kernels and no one bothered
writing the module unload support for Shark.  I'm certainly not in a
position to do that.

Since you can't unload a module while its initialization function is
running, so someone else must be holding a refcount (the insmod process).

I'm not saying that it's the right solution, I'm saying that this is how
it's evolved.

If someone has an idea on what to do about it then patches will be given
due consideration.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
