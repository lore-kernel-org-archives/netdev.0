From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 31/31] timer: Switch to testing for .function instead of .data
Date: Sat, 02 Sep 2017 15:47:20 +0200
Message-ID: <1857082.urnTVIQKcg@aspire.rjw.lan>
References: <1504222183-61202-1-git-send-email-keescook@chromium.org> <1504222183-61202-32-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Thomas Gleixner <tglx@linutronix.de>, Pavel Machek <pavel@ucw.cz>,
        Len Brown <len.brown@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        linux-pm@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-input@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cloudserver094114.home.net.pl ([79.96.170.134]:60563 "EHLO
        cloudserver094114.home.net.pl" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752441AbdIBN4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 09:56:07 -0400
In-Reply-To: <1504222183-61202-32-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, September 1, 2017 1:29:43 AM CEST Kees Cook wrote:
> In several places, .data is checked for initialization to gate early
> calls to del_timer_sync(). Checking for .function is equally valid, so
> switch to this in all callers.
> 
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Pavel Machek <pavel@ucw.cz>
> Cc: Len Brown <len.brown@intel.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
> Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
> Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: linux-pm@vger.kernel.org
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-input@vger.kernel.org
> Cc: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  drivers/base/power/wakeup.c                 |  3 +--
>  drivers/infiniband/hw/hfi1/chip.c           |  6 ++----
>  drivers/infiniband/hw/hfi1/init.c           |  2 +-
>  drivers/infiniband/hw/qib/qib_iba7220.c     |  2 +-
>  drivers/infiniband/hw/qib/qib_iba7322.c     |  2 +-
>  drivers/infiniband/hw/qib/qib_init.c        | 14 +++++---------
>  drivers/infiniband/hw/qib/qib_mad.c         |  2 +-
>  drivers/input/input.c                       |  5 ++---
>  drivers/net/ethernet/intel/i40e/i40e_main.c |  2 +-
>  9 files changed, 15 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/base/power/wakeup.c b/drivers/base/power/wakeup.c
> index 144e6d8fafc8..79a3c1b204af 100644
> --- a/drivers/base/power/wakeup.c
> +++ b/drivers/base/power/wakeup.c
> @@ -479,8 +479,7 @@ static bool wakeup_source_not_registered(struct wakeup_source *ws)
>  	 * Use timer struct to check if the given source is initialized
>  	 * by wakeup_source_add.
>  	 */
> -	return ws->timer.function != pm_wakeup_timer_fn ||
> -		   ws->timer.data != (unsigned long)ws;
> +	return ws->timer.function != pm_wakeup_timer_fn;
>  }
>  
>  /*

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

for the above.

Thanks!
