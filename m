From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: [patch 04/26] net/ixgb_osdep: replace schedule_timeout() with msleep()
Date: Tue, 8 Mar 2005 05:24:41 -0800
Message-ID: <5fc59ff305030805243de69624@mail.gmail.com>
References: <20050306103248.7C3A21F1F0@trashy.coderock.org>
Reply-To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, nacc@us.ibm.com,
        janitor@sternwelten.at
To: "domen@coderock.org" <domen@coderock.org>
In-Reply-To: <20050306103248.7C3A21F1F0@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

No. This would not work. You cannot replace msec_delay with msleep.
You probably could replace the set_current_task/schedule_timeout with
msleep. msleep does not check for the correct context, and if one were
to call msec_delay from interrupt context, the kernel would panic.

ganesh.


On Sun, 06 Mar 2005 11:32:48 +0100, domen@coderock.org
<domen@coderock.org> wrote:
> 
> 
> Use msleep() instead of schedule_timeout()
> to guarantee the task delays as expected. I was told earlier that the
> in_interrupt() check is not necessary. It would be nice to get some
> verification of this (i.e. the driver functions the same without it).
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> Signed-off-by: Domen Puncer <domen@coderock.org>
> ---
> 
> kj-domen/drivers/net/ixgb/ixgb_osdep.h |    8 +-------
> 1 files changed, 1 insertion(+), 7 deletions(-)
> 
> diff -puN drivers/net/ixgb/ixgb_osdep.h~msleep-drivers_net_ixgb_ixgb_osdep drivers/net/ixgb/ixgb_osdep.h
> --- kj/drivers/net/ixgb/ixgb_osdep.h~msleep-drivers_net_ixgb_ixgb_osdep 2005-03-05 16:09:27.000000000 +0100
> +++ kj-domen/drivers/net/ixgb/ixgb_osdep.h      2005-03-05 16:09:27.000000000 +0100
> @@ -41,13 +41,7 @@
> #include <linux/sched.h>
> 
> #ifndef msec_delay
> -#define msec_delay(x)  do { if(in_interrupt()) { \
> -                               /* Don't mdelay in interrupt context! */ \
> -                               BUG(); \
> -                       } else { \
> -                               set_current_state(TASK_UNINTERRUPTIBLE); \
> -                               schedule_timeout((x * HZ)/1000 + 2); \
> -                       } } while(0)
> +#define msec_delay(x)  msleep(x)
> #endif
> 
> #define PCI_COMMAND_REGISTER   PCI_COMMAND
> _
> 
>
