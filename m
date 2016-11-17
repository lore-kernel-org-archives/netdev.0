From: Jerome Brunet <jbrunet@baylibre.com>
Subject: Re: [PATCH net 1/3] net: phy: realtek: add eee advertisement
 disable options
Date: Thu, 17 Nov 2016 22:48:37 +0100
Message-ID: <1479419317.17538.75.camel@baylibre.com>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
         <1479220154-25851-2-git-send-email-jbrunet@baylibre.com>
         <CANAwSgTjG8G0U+A1p7hOKND9rjY4BzZfPgyWWHAEryYkHj_UOw@mail.gmail.com>
         <1479378055.17538.57.camel@baylibre.com>
         <CANAwSgTB5=8tVj1FrZF3EgjK5mjUMwLYb90NeWSFDCsRjsuB6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devicetree <devicetree@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Kevin Hilman <khilman@baylibre.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Andre Roth <neolynx@gmail.com>,
        linux-amlogic@lists.infradead.org, Carlo Caione <carlo@caione.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Anand Moon <linux.amoon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38182 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbcKQVsk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 16:48:40 -0500
Received: by mail-wm0-f41.google.com with SMTP id f82so175140759wmf.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 13:48:39 -0800 (PST)
In-Reply-To: <CANAwSgTB5=8tVj1FrZF3EgjK5mjUMwLYb90NeWSFDCsRjsuB6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-17 at 23:30 +0530, Anand Moon wrote:
> Hi Jerone,
> 
> > > How about adding callback functionality for .soft_reset to handle
> > > BMCR
> > > where we update the Auto-Negotiation for the phy,
> > > as per the datasheet of the rtl8211f.

I think BMCR is already pretty well handled by the genphy, don't you
think ?

> > 
> > I'm not sure I understand how this would help with our issue (and
> > EEE).
> > Am I missing something or is it something unrelated that you would
> > like
> > to see happening on this driver ?
> > 
> [snip]
> 
> I was just tying other phy module to understand the feature.
> But in order to improve  the throughput I tried to integrate blow u-
> boot commit.
> 
> commit 3d6af748ebd831524cb22a29433e9092af469ec7
> Author: Shengzhou Liu <Shengzhou.Liu@freescale.com>
> Date:   Thu Mar 12 18:54:59 2015 +0800
> 
>     net/phy: Add support for realtek RTL8211F
> 
>     RTL8211F has different registers from RTL8211E.
>     This patch adds support for RTL8211F PHY which
>     can be found on Freescale's T1023 RDB board.
> 
> And added the similar functionality to  .config_aneg    =
> &rtl8211f_config_aneg,
> 

I assume this is the commit you are referring to : 
http://git.denx.de/?p=u-boot.git;a=commit;h=3d6af748ebd831524cb22a29433
e9092af469ec7

I tried looking a this particular commit and the other ones in
realtek.c history of u-boot. I don't really see what it does that linux
is not already doing.

> And I seem to have better results in through put with periodic drop
> but it recovers.
> -----
> odroid@odroid64:~$ iperf3 -c 10.0.0.102 -p 2006 -i 1 -t 100 -V
> iperf 3.0.11
> Linux odroid64 4.9.0-rc5-xc2ml #18 SMP PREEMPT Thu Nov 17 22:56:00 

[...]

> 
> Test Complete. Summary Results:
> [ ID] Interval           Transfer     Bandwidth       Retr
> [  4]   0.00-100.00 sec  10.5 GBytes   902
> Mbits/sec    4             sender
> [  4]   0.00-100.00 sec  10.5 GBytes   902
> Mbits/sec                  receiver
> CPU Utilization: local/sender 5.6% (0.2%u/5.4%s), remote/receiver
> 17.1% (1.2%u/15.9%s)
> 

That's the kind of throughput we have on the C2 once the link is
reliable (with EEE switch off for GbE)

> Can your confirm this at your end.
> Once confirm I will try to send this as a fix for this issue.
> 

I'm testing the code to disable EEE in a generic way. I'll post the RFC
for it asap.

> -Best Regards
> Anand Moon
