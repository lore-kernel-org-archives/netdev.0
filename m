From: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Subject: [2.6.21 patch] unconditionally enable SYSFS_DEPRECATED
Date: Tue, 6 Mar 2007 00:40:52 +0100
Message-ID: <20070305234052.GR3441@stusta.de>
References: <20070304220857.GH23311@waste.org> <1173051564.6131.13.camel@johannes.berg> <20070305002550.GI23311@waste.org> <20070305011729.GB7681@kroah.com> <20070305125950.GC26781@thunk.org> <20070305185813.GA31465@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070305185813.GA31465-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 10:58:13AM -0800, Greg KH wrote:
> 
> Ok, how about the following patch.  Is it acceptable to everyone?
> 
> thanks,
> 
> greg k-h
> 
> ---
>  init/Kconfig |   13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> --- gregkh-2.6.orig/init/Kconfig
> +++ gregkh-2.6/init/Kconfig
> @@ -290,8 +290,17 @@ config SYSFS_DEPRECATED
>  	  that belong to a class, back into the /sys/class heirachy, in
>  	  order to support older versions of udev.
>  
> -	  If you are using a distro that was released in 2006 or later,
> -	  it should be safe to say N here.
> +	  If you are using an OpenSuSE, Gentoo, Ubuntu, or Fedora
> +	  release from 2007 or later, it should be safe to say N here.
> +
> +	  If you are using Debian or other distros that are slow to
> +	  update HAL, please say Y here.
>...

The sane solution seems to be to enable SYSFS_DEPRECATED unconditionally 
for all users, and schedule it's removal for mid-2008 (or later).

12 months after the first _release_ of a HAL that can live without seems 
to be the first time when we can consider getting rid of it, since all 
distributions with at least one release a year should ship it by then.

Currently, SYSFS_DEPRECATED is only a trap for users.

Suggested patch below.

cu
Adrian


<--  snip  -->


unconditionally enable SYSFS_DEPRECATED

This patch unconditionally enables SYSFS_DEPRECATED and schedules it's
removal for July 2008.

Currently, SYSFS_DEPRECATED is only a trap for users accidentally
disabling it.

In July 2008, all distributions with at least one release a year should
be able to run without SYSFS_DEPRECATED.

Signed-off-by: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index c3b1430..b0bce93 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -316,3 +316,13 @@ Why:	The option/code is
 Who:	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
 
 ---------------------------
+
+What:	deprecated sysfs files (CONFIG_SYSFS_DEPRECATED)
+When:	July 2008
+Why:	None of these features or values should be used any longer,
+	as they export driver core implementation details to userspace
+	or export properties which can't be kept stable across kernel
+	releases.
+Who:	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
+
+---------------------------
diff --git a/init/Kconfig b/init/Kconfig
index f977086..f652b6f 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -274,24 +274,9 @@ config CPUSETS
 	  Say N if unsure.
 
 config SYSFS_DEPRECATED
-	bool "Create deprecated sysfs files"
+	bool
 	default y
 	help
-	  This option creates deprecated symlinks such as the
-	  "device"-link, the <subsystem>:<name>-link, and the
-	  "bus"-link. It may also add deprecated key in the
-	  uevent environment.
-	  None of these features or values should be used today, as
-	  they export driver core implementation details to userspace
-	  or export properties which can't be kept stable across kernel
-	  releases.
-
-	  If enabled, this option will also move any device structures
-	  that belong to a class, back into the /sys/class heirachy, in
-	  order to support older versions of udev.
-
-	  If you are using a distro that was released in 2006 or later,
-	  it should be safe to say N here.
 
 config RELAY
 	bool "Kernel->user space relay support (formerly relayfs)"
