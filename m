From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net sched actions: decrement module reference
 count after table flush.
Date: Fri, 24 Feb 2017 09:58:21 -0800
Message-ID: <CAM_iQpW9E8UWDCVbqDqZ7pkjh5kTEO7W_=2Qk_aRUP4HMXypRQ@mail.gmail.com>
References: <1487952032-508-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34200 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751163AbdBXR6n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 12:58:43 -0500
Received: by mail-wm0-f68.google.com with SMTP id m70so4127756wma.1
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 09:58:42 -0800 (PST)
In-Reply-To: <1487952032-508-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 24, 2017 at 8:00 AM, Roman Mashak <mrv@mojatatu.com> wrote:
> When tc actions are loaded as a module and no actions have been installed,
> flushing them would result in actions removed from the memory, but modules
> reference count not being decremented, so that the modules would not be
> unloaded.
>
> Following is example with GACT action:
>
> % sudo modprobe act_gact
> % lsmod
> Module                  Size  Used by
> act_gact               16384  0
> %
> % sudo tc actions ls action gact
> %
> % sudo tc actions flush action gact
> % lsmod
> Module                  Size  Used by
> act_gact               16384  1
> % sudo tc actions flush action gact
> % lsmod
> Module                  Size  Used by
> act_gact               16384  2
> % sudo rmmod act_gact
> rmmod: ERROR: Module act_gact is in use
> ....
>
> After the fix:
> % lsmod
> Module                  Size  Used by
> act_gact               16384  0
> %
> % sudo tc actions add action pass index 1
> % sudo tc actions add action pass index 2
> % sudo tc actions add action pass index 3
> % lsmod
> Module                  Size  Used by
> act_gact               16384  3
> %
> % sudo tc actions flush action gact
> % lsmod
> Module                  Size  Used by
> act_gact               16384  0
> %
> % sudo tc actions flush action gact
> % lsmod
> Module                  Size  Used by
> act_gact               16384  0
> % sudo rmmod act_gact
> % lsmod
> Module                  Size  Used by
> %
>
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Fixes commit f97017cdefefdb6a0e19266024b0c6f9fd411eeb ?

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
