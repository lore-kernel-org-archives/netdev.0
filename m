From: "Noah J. Misch" <noah@caltech.edu>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Mon, 13 Oct 2003 22:17:57 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.58.0310122215370.24@inky>
References: <Pine.GSO.4.58.0310101519330.9806@inky> <20031012191725.093139d5.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: maxk@qualcomm.com, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20031012191725.093139d5.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy,

That fix looks like the best to me.  I did notice also that proc_bt_rfcomm and
proc_bt_hci have similar #ifdef wrappers.  I think that's okay since they aren't
EXPORT_SYMBOL-ed, and they're used in fewer places.

FYI, IPX won't compile without CONFIG_PROC_FS at this time.  The merged patch
depended on a patch that I sent to Linus and posted to linux-kernel alongside
the IPX patch.  I also sent them to linux-net (accidentally, instead of netdev).
I may need to resend that patch.  In the mean time, if you actually need to use
IPX without procfs, you can grab the patch (and rationale) here:
http://www.ussg.iu.edu/hypermail/linux/kernel/0310.1/0452.html

FYI #2, from elsewhere in the department of fixing exotic breakage, I'm working
on patches that will allow one to compile a linux kernel under Unix and other
similar systems.  I've gotten allnoconfig for i386 to build from Solaris 2.7 on
sun4u, but a number of the userspace tools that support the build process of
optional components need a bit more help.

On Sun, 12 Oct 2003, Randy.Dunlap wrote:

> On Fri, 10 Oct 2003 16:06:29 -0700 (PDT) "Noah J. Misch" <noah@caltech.edu> wrote:
>
> | > There are several other drivers/protocols that don't build
> | > with PROC_FS=n, like arlan, siimage, ipx, llc, and bluetooth.
> |
> | I put in a patch for ipx yesterday, and I have patches for siimage and llc
> | pretty much ready to go.  I noticed the others but I have not done much.
>
> ipx is merged.  I'll leave siimage and llc to Noah.
> Patch below fixes af_bluetooth.  Comments on it?
>
> --
> ~Randy
>
>
> patch_name:	bt_noprocfs.patch
> patch_version:	2003-10-12.19:11:03
> author:		Randy.Dunlap <rddunlap@osdl.org>
> description:	af_bluetooth uses/needs proc_bt when PROC_FS=n
> product:	Linux
> product_versions: 2.6.0-test7
> diffstat:	=
>  net/bluetooth/af_bluetooth.c |    2 --
>  1 files changed, 2 deletions(-)
>
>
> diff -Naur ./net/bluetooth/af_bluetooth.c~btprocfs ./net/bluetooth/af_bluetooth.c
> --- ./net/bluetooth/af_bluetooth.c~btprocfs	2003-10-08 12:24:02.000000000 -0700
> +++ ./net/bluetooth/af_bluetooth.c	2003-10-12 19:09:11.000000000 -0700
> @@ -56,9 +56,7 @@
>  #define BT_DBG( A... )
>  #endif
>
> -#ifdef CONFIG_PROC_FS
>  struct proc_dir_entry *proc_bt;
> -#endif
>
>  /* Bluetooth sockets */
>  #define BT_MAX_PROTO	5
>
>
