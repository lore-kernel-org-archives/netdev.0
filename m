From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 16/18]  net/airo: replace 	schedule_timeout() with msleep()/msleep_interuptible()
Date: Sun, 31 Oct 2004 06:01:51 -0500
Message-ID: <4184C61F.2080906@pobox.com>
References: <E1CO1wE-0002hu-WE@sputnik>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
In-Reply-To: <E1CO1wE-0002hu-WE@sputnik>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

janitor@sternwelten.at wrote:
> Any comments would be appreciated.
> 
> Description: Use msleep()/msleep_interruptible() [as appropriate]
> instead of schedule_timeout() to guarantee the task delays as
> expected. Also uses set_current_state() instead of direct assignment of
> current->state in one place.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> 
> ---
> 
>  linux-2.6.10-rc1-max/drivers/net/wireless/airo.c |   27 ++++++++---------------
>  1 files changed, 10 insertions(+), 17 deletions(-)
> 
> diff -puN drivers/net/wireless/airo.c~msleep+msleep_interruptible-drivers_net_wireless_airo drivers/net/wireless/airo.c
> --- linux-2.6.10-rc1/drivers/net/wireless/airo.c~msleep+msleep_interruptible-drivers_net_wireless_airo	2004-10-24 17:05:35.000000000 +0200
> +++ linux-2.6.10-rc1-max/drivers/net/wireless/airo.c	2004-10-24 17:05:35.000000000 +0200
> @@ -1699,9 +1699,8 @@ static int readBSSListRid(struct airo_in
>  			issuecommand(ai, &cmd, &rsp);
>  			up(&ai->sem);
>  			/* Let the command take effect */
> -			set_current_state (TASK_INTERRUPTIBLE);
>  			ai->task = current;
> -			schedule_timeout (3*HZ);
> +			msleep_interruptible(3*1000);
>  			ai->task = NULL;
>  		}
>  	rc = PC4500_readrid(ai, first ? RID_BSSLISTFIRST : RID_BSSLISTNEXT,

use ssleep() here


> @@ -2950,7 +2947,7 @@ static int airo_thread(void *data) {
>  				}
>  				break;
>  			}
> -			current->state = TASK_RUNNING;
> +			set_current_state(TASK_RUNNING);
>  			remove_wait_queue(&ai->thr_wait, &wait);
>  			locked = 1;
>  		}

why are you adding barriers?

	Jeff
