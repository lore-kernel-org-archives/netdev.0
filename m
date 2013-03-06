From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: igb_down from bottom half context
Date: Wed, 6 Mar 2013 09:38:03 +0530
Message-ID: <CAGZFCEHrzDDtO8HGaUhuUb_vNddKyiXPzasnkvTqLOqS9SwaDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-newbie <linux-newbie@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f176.google.com ([209.85.128.176]:32949 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab3CFEIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:08:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I  have kernel timer which  check for flag.

if(flag ) {
          igb_down(adapter);
 } else {
         igb_up(adapter);
 }


I could see a kernel crash; because  there are a lot of  msleep() in
igb_down function.

#define msleep(x)    do { set_current_state(TASK_UNINTERRUPTIBLE); \
                                schedule_timeout((x * HZ)/1000 + 2); \
                              } while (0)

sleep() is called from bottom half context; this is the cause of kernel crash.

1) Since timer call back dont have process context associated with it;
i think , "current" points to the last preempted task ?
2) How can i introduce delays in interrupt context to avoid the kernel
crash. mdelay()  will work ?
3) is there any better mechanism to do this job ?

Thanks,
Ratheesh
