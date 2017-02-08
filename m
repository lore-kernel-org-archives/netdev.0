From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: loopback device reference count leakage
Date: Wed, 8 Feb 2017 13:50:57 -0800
Message-ID: <CAM_iQpVpjhSLGrqQAL4N=X3hqcZBQd1F+2QzO+7rmLJijq4hRA@mail.gmail.com>
References: <BY1PR17MB0101922AF9444B40E31B3B3CA1750@BY1PR17MB0101.namprd17.prod.outlook.com>
 <CAM_iQpXQ5MyL_KYNctZuZLv_w-ai3pmXKswOLXYeEYmVBdQqJA@mail.gmail.com>
 <CO2PR17MB01050D56F6EE3C8D54B00CAAA1770@CO2PR17MB0105.namprd17.prod.outlook.com>
 <CAM_iQpWJmXnsZ4D870aEZ+HL3pfaZU3HyunyxnhG9=EHS0Tcdg@mail.gmail.com>
 <CO2PR17MB01057D980A6B7827B48BD7A7A1760@CO2PR17MB0105.namprd17.prod.outlook.com>
 <CO2PR17MB0105551B80302C4B5657CA80A1430@CO2PR17MB0105.namprd17.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kaiwen Xu <kevin@kevxu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37270 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdBHWAJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 17:00:09 -0500
Received: by mail-wm0-f53.google.com with SMTP id v77so1893581wmv.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 13:58:44 -0800 (PST)
In-Reply-To: <CO2PR17MB0105551B80302C4B5657CA80A1430@CO2PR17MB0105.namprd17.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2017 at 6:32 PM, Kaiwen Xu <kevin@kevxu.net> wrote:
> Hi Cong,
>
> I did some more testing, seems like your second assumption is correct.
> There is indeed some things holding the references to a particular dst
> which preventing it to be gc'ed.

Excellent!

>
> I added logging to each dst_hold (or dst_hold_safe, or
> skb_dst_force_safe) and dst_release, which formatted as following:
>
> <dev name> (<protocol>) [<dst addr>]: dst_release / dst_hold ... <refcnt> <caller function>
>
> And inside dst_gc_task(), I added logging when gc delay occurred,
> formatted as:
>
> [dst_gc_task] <dev name> (<protocol>): delayed <refcnt>
>
> I have the log attached.

The following line looks suspicious:

Feb  6 16:27:24 <hostname> kernel: [63589.458067] [dst_gc_task]
lodebug (2): delayed 19

Looks like you ended up having one dst whose refcnt is 19 in GC,
and this lasted for a rather long time for some reason.

It is hard to know if it is a refcnt leak even with your log, since there were
4K+ refcnt'ing happened on that dst...

Meanwhile, can you share your setup of your container? What network device
do you use in your container? How is it connected to outside?

Thanks.
