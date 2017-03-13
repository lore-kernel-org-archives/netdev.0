From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net 1/3] cpsw/netcp: cpts depends on posix_timers
Date: Mon, 13 Mar 2017 17:55:54 +0100
Message-ID: <CAK8P3a3N6p6YfP+6Q7KQ-Sv5sPKfJZT2Bf3vJw9bzPAjGTr17g@mail.gmail.com>
References: <20161216092017.2560717-1-arnd@arndb.de> <alpine.LFD.2.20.1612161317510.17914@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>,
        =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>, WingMan Kwok <w-kwok2@ti.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36013 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752397AbdCMQz4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 12:55:56 -0400
In-Reply-To: <alpine.LFD.2.20.1612161317510.17914@knanqh.ubzr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2016 at 7:18 PM, Nicolas Pitre <nicolas.pitre@linaro.org> wrote:
> On Fri, 16 Dec 2016, Arnd Bergmann wrote:
>
>> With posix timers having become optional, we get a build error with
>> the cpts time sync option of the CPSW driver:
>>
>> drivers/net/ethernet/ti/cpts.c: In function 'cpts_find_ts':
>> drivers/net/ethernet/ti/cpts.c:291:23: error: implicit declaration of function 'ptp_classify_raw';did you mean 'ptp_classifier_init'? [-Werror=implicit-function-declaration]
>>
>> It really makes no sense to build this driver if we can't use PTP,
>> so it's better to go back to 'select PTP_1588_CLOCK' but instead
>> add a dependency on POSIX_TIMERS.
>
> Why not depend on PTP_1588_CLOCK directly instead?

Sorry for dropping the ball on this. I just noticed my two patches in my patch
are still required, so I'm resending them now.

I think using 'select' here is better for consistency as we use 'imply'
elsewhere, and mixing the two might cause circular dependencies.

If you still have concerns about this, please follow up on the resend.

      Arnd
