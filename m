From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH v2] isdnloop: fix and simplify isdnloop_init()
Date: Fri, 03 Aug 2012 10:47:28 +0200
Message-ID: <501B9020.7030200@linux-pingi.de>
References: <20120802110543.GA21745@localhost>
 <20120802.162156.1853851468137303302.davem@davemloft.net>
 <20120803073240.GA12723@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, isdn@linux-pingi.de, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, joe@perches.com,
 David Miller <davem@davemloft.net>, dan.carpenter@oracle.com
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20120803073240.GA12723@localhost>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Am 03.08.2012 09:32, schrieb Fengguang Wu:
> On Thu, Aug 02, 2012 at 04:21:56PM -0700, David Miller wrote:
>> From: Fengguang Wu <fengguang.wu@intel.com>
>> Date: Thu, 2 Aug 2012 19:05:43 +0800
>>
>>> Fix a buffer overflow bug by removing the revision transform code.
>>>
>>> [   22.016214] isdnloop-ISDN-driver Rev 1.11.6.7 
>>> [   22.097508] isdnloop: (loop0) virtual card added
>>> [   22.174400] Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in: ffffffff83244972
>>> [   22.174400] 
>>> [   22.436157] Pid: 1, comm: swapper Not tainted 3.5.0-bisect-00018-gfa8bbb1-dirty #129
>>> [   22.624071] Call Trace:
>>> [   22.720558]  [<ffffffff832448c3>] ? CallcNew+0x56/0x56
>>> [   22.815248]  [<ffffffff8222b623>] panic+0x110/0x329
>>> [   22.914330]  [<ffffffff83244972>] ? isdnloop_init+0xaf/0xb1
>>> [   23.014800]  [<ffffffff832448c3>] ? CallcNew+0x56/0x56
>>> [   23.090763]  [<ffffffff8108e24b>] __stack_chk_fail+0x2b/0x30
>>> [   23.185748]  [<ffffffff83244972>] isdnloop_init+0xaf/0xb1
>>>
>>> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
>>
>> The reason the "$Revision ..." prefix is there is so that automated
>> version control tools will change the string automatically when code
>> is committed in CVS.
>>
>> In the GIT era this revision style is obsolete.
>>
>> Therefore you might as well just delete this crap altogether.
> 
> OK. The below updated version will simply print the hard coded
> revision number as it's unlikely to change any more.
> 
> Thanks,
> Fengguang
> ---
> isdnloop: fix and simplify isdnloop_init
> 
> Fix a buffer overflow bug by hard coding the revision number.
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
>  drivers/isdn/isdnloop/isdnloop.c |   12 +-----------
>  1 file changed, 1 insertion(+), 11 deletions(-)
> 
> --- linux.orig/drivers/isdn/isdnloop/isdnloop.c	2012-08-03 15:24:49.047544323 +0800
> +++ linux/drivers/isdn/isdnloop/isdnloop.c	2012-08-03 15:27:39.503548375 +0800
> @@ -16,7 +16,6 @@
>  #include <linux/sched.h>
>  #include "isdnloop.h"
>  
> -static char *revision = "$Revision: 1.11.6.7 $";
>  static char *isdnloop_id = "loop0";
>  
>  MODULE_DESCRIPTION("ISDN4Linux: Pseudo Driver that simulates an ISDN card");
> @@ -1494,16 +1493,7 @@ isdnloop_addcard(char *id1)
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
> +	printk(KERN_NOTICE "isdnloop-ISDN-driver Rev 1.11.6.7\n");
>  
>  	if (isdnloop_id)
>  		return (isdnloop_addcard(isdnloop_id));
> 
> 
You could remove the revision completely, even from the printk.
Maybe use  pr_notice("isdnloop-ISDN driver loaded\n");

Best Regards
Karsten
