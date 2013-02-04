From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Mon, 4 Feb 2013 10:22:23 +0800
Message-ID: <CAHrpEqSLx-J-1SYC6OapqidY+U3acnTmNyOj8UrNRZwYZRXCoQ@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<20130202.230851.809969826800130930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank.Li@freescale.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, shawn.guo@linaro.org, B38611@freescale.com,
	s.hauer@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:46647 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730Ab3BDCWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 21:22:25 -0500
Received: by mail-wi0-f179.google.com with SMTP id ez12so2386811wid.12
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 18:22:23 -0800 (PST)
In-Reply-To: <20130202.230851.809969826800130930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/3 David Miller <davem@davemloft.net>:
> From: Frank Li <Frank.Li@freescale.com>
> Date: Fri, 1 Feb 2013 16:56:26 +0800
>
>> @@ -1607,6 +1607,7 @@ static int fec_enet_init(struct net_device *ndev)
>>       }
>>
>>       spin_lock_init(&fep->hw_lock);
>> +     spin_lock_init(&fep->tmreg_lock);
>
> This breaks the build, tmreg_lock is only present in certain
> configurations.

No, FEC have changed to check dramatically instead of static config.
You can look fec.h.  tmreg_lock is always defined.

        struct  napi_struct napi;

        struct ptp_clock *ptp_clock;
        struct ptp_clock_info ptp_caps;
        unsigned long last_overflow_check;
        spinlock_t tmreg_lock;
        struct cyclecounter cc;
        struct timecounter tc;
        int rx_hwtstamp_filter;
        u32 base_incval;
        u32 cycle_speed;
        int hwts_rx_en;
        int hwts_tx_en;
        struct timer_list time_keep;

best regards
Frank Li
