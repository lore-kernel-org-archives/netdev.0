From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] isdnloop: fix and simplify isdnloop_init()
Date: Thu, 2 Aug 2012 18:44:56 +0800
Message-ID: <20120802104456.GA21537@localhost>
References: <20120802040158.GA11860@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	Karsten Keil <isdn@linux-pingi.de>,
	Joe Perches <joe@perches.com>,
	"open list:ISDN SUBSYSTEM" <netdev@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120802040158.GA11860@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Add more CC]

On Thu, Aug 02, 2012 at 12:01:58PM +0800, Fengguang Wu wrote:
> Remove the non-sense isdnloop revision transform code, so as to fix:
> 
> [   22.016214] isdnloop-ISDN-driver Rev 1.11.6.7 
> [   22.097508] isdnloop: (loop0) virtual card added
> [   22.174400] Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in: ffffffff83244972
> [   22.174400] 
> [   22.436157] Pid: 1, comm: swapper Not tainted 3.5.0-bisect-00018-gfa8bbb1-dirty #129
> [   22.624071] Call Trace:
> [   22.720558]  [<ffffffff832448c3>] ? CallcNew+0x56/0x56
> [   22.815248]  [<ffffffff8222b623>] panic+0x110/0x329
> [   22.914330]  [<ffffffff83244972>] ? isdnloop_init+0xaf/0xb1
> [   23.014800]  [<ffffffff832448c3>] ? CallcNew+0x56/0x56
> [   23.090763]  [<ffffffff8108e24b>] __stack_chk_fail+0x2b/0x30
> [   23.185748]  [<ffffffff83244972>] isdnloop_init+0xaf/0xb1
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  drivers/isdn/isdnloop/isdnloop.c |   13 ++-----------
>  1 file changed, 2 insertions(+), 11 deletions(-)
> 
> --- linux.orig/drivers/isdn/isdnloop/isdnloop.c	2012-05-24 19:03:06.748430938 +0800
> +++ linux/drivers/isdn/isdnloop/isdnloop.c	2012-08-02 11:57:16.806437909 +0800
> @@ -16,7 +16,7 @@
>  #include <linux/sched.h>
>  #include "isdnloop.h"
>  
> -static char *revision = "$Revision: 1.11.6.7 $";
> +static char *revision = "1.11.6.7";
>  static char *isdnloop_id = "loop0";
>  
>  MODULE_DESCRIPTION("ISDN4Linux: Pseudo Driver that simulates an ISDN card");
> @@ -1494,16 +1494,7 @@ isdnloop_addcard(char *id1)
>  static int __init
>  isdnloop_init(void)
>  {
> -	char *p;
> -	char rev[10];
> -
> -	if ((p = strchr(revision, ':'))) {
> -		strcpy(rev, p + 1);
> -		p = strchr(rev, '$');
> -		*p = 0;
> -	} else
> -		strcpy(rev, " ??? ");
> -	printk(KERN_NOTICE "isdnloop-ISDN-driver Rev%s\n", rev);
> +	printk(KERN_NOTICE "isdnloop-ISDN-driver Rev %s\n", revision);
>  
>  	if (isdnloop_id)
>  		return (isdnloop_addcard(isdnloop_id));
