From: crow <crow@linux.org.ba>
Subject: Re: ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and
 stalled after some traffic
Date: Sun, 11 Jun 2017 19:03:11 +0200
Message-ID: <CAG_g8w6iEiJ4V2M1=toWWqi1D7H2_p08ceWsbgZ1=PrEGQ2HkA@mail.gmail.com>
References: <CAG_g8w7PND+6r17cLoTG0rG0CqVDA-Z9kr8Zi+TOq5Qbpd9Gtw@mail.gmail.com>
 <CAG_g8w40V_u7JnX+EuNvCLmB2dAzuk_TgMkkKT9pn-SLBRi1pA@mail.gmail.com>
 <20170610152741.GB26740@lunn.ch> <CAG_g8w71SWc_X2U9pNWLVheO9Jf4ydPznAVp1x-Y9kwU3qhf1A@mail.gmail.com>
 <20170611152102.GA16021@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:37351 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751751AbdFKRDN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 13:03:13 -0400
Received: by mail-it0-f53.google.com with SMTP id m47so13394667iti.0
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 10:03:13 -0700 (PDT)
In-Reply-To: <20170611152102.GA16021@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Sun, Jun 11, 2017 at 5:21 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> Thank your for the suggestion, and thanks Martin to explaining me over
>> IRC what actually I should do.
>>
>> I recompiled mainline kernel 4.12-rc4 with the Amlogic driver:
>> replaced drivers/net/phy/meson-gxl.c with
>> https://github.com/khadas/linux/blob/ubuntu-4.9/drivers/amlogic/ethernet/phy/amlogic.c
>>
>> But this did not solve the issue. As soon as i start git clone i lose
>> network connection to device (no session timeout/disconnect this time,
>> but I am unable to reconnect over SSH or to get OK ping replay back).
>

1) First problem reported I can't reproduce anymore, every reboot/cold
boot with mainline kernel the Ethernet speed is detected as
"100Mbps/Full" , but as seen in first post there was this issue.

2) see below

> So this shows it is more than a PHY problem. The Ethernet MAC driver
> is probably also part of the problem.

There are some stmmac fixes [1] in soon to be rc5, compiled current
master (without amlogic.c) with the fixes but for me the issue still
persist. I will compile once released rc5 with amlogic.c and report
back.

> Are there any mainline kernels which work O.K?

Khadas VIM support was added in 4.12-rc1. And I did test all four rc's
but without success.

>     Andrew

[1] https://github.com/torvalds/linux/commit/426849e6611f2092553f8d53372ae310818a6292
