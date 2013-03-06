From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: igb_down from bottom half context
Date: Wed, 6 Mar 2013 17:38:06 +0000
Message-ID: <1362591486.3126.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAGZFCEHrzDDtO8HGaUhuUb_vNddKyiXPzasnkvTqLOqS9SwaDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	linux-newbie <linux-newbie@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:65334 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454Ab3CFRi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 12:38:27 -0500
In-Reply-To: <CAGZFCEHrzDDtO8HGaUhuUb_vNddKyiXPzasnkvTqLOqS9SwaDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-06 at 09:38 +0530, ratheesh kannoth wrote:
> I  have kernel timer which  check for flag.
> 
> if(flag ) {
>           igb_down(adapter);
>  } else {
>          igb_up(adapter);
>  }
> 
> 
> I could see a kernel crash; because  there are a lot of  msleep() in
> igb_down function.
> 
> #define msleep(x)    do { set_current_state(TASK_UNINTERRUPTIBLE); \
>                                 schedule_timeout((x * HZ)/1000 + 2); \
>                               } while (0)
> 
> sleep() is called from bottom half context; this is the cause of kernel crash.
> 
> 1) Since timer call back dont have process context associated with it;
> i think , "current" points to the last preempted task ?
> 2) How can i introduce delays in interrupt context to avoid the kernel
> crash. mdelay()  will work ?
> 3) is there any better mechanism to do this job ?

Use a work item and schedule_work().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
