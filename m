From: Kaiwen Xu <kevin@kevxu.net>
Subject: Re: loopback device reference count leakage
Date: Fri, 27 Jan 2017 03:15:52 +0000
Message-ID: <CO2PR17MB01057D980A6B7827B48BD7A7A1760@CO2PR17MB0105.namprd17.prod.outlook.com>
References: <BY1PR17MB0101922AF9444B40E31B3B3CA1750@BY1PR17MB0101.namprd17.prod.outlook.com>
 <CAM_iQpXQ5MyL_KYNctZuZLv_w-ai3pmXKswOLXYeEYmVBdQqJA@mail.gmail.com>
 <CO2PR17MB01050D56F6EE3C8D54B00CAAA1770@CO2PR17MB0105.namprd17.prod.outlook.com>
 <CAM_iQpWJmXnsZ4D870aEZ+HL3pfaZU3HyunyxnhG9=EHS0Tcdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay004-omc3s14.hotmail.com ([65.54.190.152]:52849 "EHLO
        BAY004-OMC3S14.hotmail.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753347AbdA0DW4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 22:22:56 -0500
In-Reply-To: <CAM_iQpWJmXnsZ4D870aEZ+HL3pfaZU3HyunyxnhG9=EHS0Tcdg@mail.gmail.com>
Content-Language: en-US
Content-ID: <40D974CF939CCC429E69ED1B0402E5EB@namprd17.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 05:01:38PM -0800, Cong Wang wrote:
> I'd suggest to you add some debugging printk's to the dst refcount functions,
> or maybe just inside dst_gc_task(). I think the last dst referring to
> the loopback
> dev is still being referred at that point, which prevents GC from destroying it.

Thanks for the suggestion! I will test it out.

> Meanwhile, if it would be also helpful if you can share how you managed to
> reproduce this reliably, I saw this bug in our data center before but never
> know how to reproduce it.

I used one of our applications to reproduce the issue, to be honest, I
haven't completely isolated which part of the code is triggering the
bug. However, the suspicion is that, since the application basically
acts as a web crawler, the bug is manifested after initiating a large
amount connections to a wide range of IP addresses in a short period of
time. Hope it somewhat helps.

Thanks,
Kaiwen
