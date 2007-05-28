From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 28 May 2007 17:14:25 +0200
Message-ID: <200705281714.25841.mb@bu3sch.de>
References: <20070525172431.60affaca@freepuppy> <200705281216.51690.mb@bu3sch.de> <200705281609.49859.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705281609.49859.maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 28 May 2007 16:09:46 Maximilian Engelhardt wrote:
> On Monday 28 May 2007, Michael Buesch wrote:
> > Can you give 2.6.16 a try? The diff is not that big and we might
> > be able to find out what broke if you find out 2.6.16 works.
> > You can also try later kernels like .17, .18, .19 to further
> > reduce the patch. (You could also git-bisect, if you have the time).
> >
> I did some testing and compiled some kernels and here are the results:
> 
> I was able to find out what causes the problems for me.  I did build two 
> 2.6.21.3 kernels, and one does work fine and the other doesn't.
> 
> This is a diff of the kernel configs I used:
> 
> --- /usr/src/linux-2.6.21.3-oldconfig1/.config  2007-05-28 13:41:15.000000000 
> +0200
> +++ /usr/src/linux-2.6.21.3/.config     2007-05-28 14:46:08.000000000 +0200
> @@ -1,7 +1,7 @@
>  #
>  # Automatically generated make config: don't edit
>  # Linux kernel version: 2.6.21.3
> -# Mon May 28 13:41:15 2007
> +# Mon May 28 14:46:09 2007
>  #
>  CONFIG_X86_32=y
>  CONFIG_GENERIC_TIME=y
> @@ -32,7 +32,7 @@
>  #
>  # General setup
>  #
> -CONFIG_LOCALVERSION="-oldconfig1"
> +CONFIG_LOCALVERSION=""
>  CONFIG_LOCALVERSION_AUTO=y
>  CONFIG_SWAP=y
>  CONFIG_SYSVIPC=y
> @@ -108,9 +108,9 @@
>  #
>  # Processor type and features
>  #
> -# CONFIG_TICK_ONESHOT is not set
> +CONFIG_TICK_ONESHOT=y
>  # CONFIG_NO_HZ is not set
> -# CONFIG_HIGH_RES_TIMERS is not set
> +CONFIG_HIGH_RES_TIMERS=y
>  # CONFIG_SMP is not set
>  CONFIG_X86_PC=y
>  # CONFIG_X86_ELAN is not set
> 
> The -oldconfig1 is the kernel that had no problems and the other shows the b44 
> problem. So if High Resolution Timer Support is disabled everything works 
> fine and if I enable it the problems do appear again.
> 
> I didn't test this on my 2.6.22-rc3 kernel yet, but I guess disabling High 
> Resolution Timer Support will also solve the problem there.
> 
> The older kernels I tried also work perfectly fine and they didn't have the 
> High Resolution Timer Support yet.

So, that's interesting, indeed.
Any idea what's going on, someone? Thomas?

-- 
Greetings Michael.
