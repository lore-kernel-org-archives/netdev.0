From: Niklas =?iso-8859-1?Q?S=F6derlund?=
        <niklas.soderlund@ragnatech.se>
Subject: Re: ravb WoL interrupt flood
Date: Tue, 30 May 2017 12:29:24 +0200
Message-ID: <20170530102924.GB7484@bigcity.dyn.berto.se>
References: <CAMuHMdWmt7oB4B4OYkO59+HvEbpVLVeqB_AV2c5OnYJEUJRxRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:32870 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbdE3K32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 06:29:28 -0400
Received: by mail-lf0-f53.google.com with SMTP id m18so46659360lfj.0
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 03:29:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMuHMdWmt7oB4B4OYkO59+HvEbpVLVeqB_AV2c5OnYJEUJRxRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Geert,

Thanks for the report. I did run a 200+ loop suspend/resume without 
issues so this error is probably hard to reproduce or something changed 
since v4.11-rc1 which if IIRC was the base I used to do the tests.

All I can think of is that if the interface was down at the time the 
system was suspend. There is a bug in  the driver which is in 
renesas-drivers related to that. But given that you woken up by WoL that 
is probably not the case :-)

I will do more tests and see if I can reproduce this once I'm back in 
Stockholm.


On 2017-05-30 11:23:23 +0200, Geert Uytterhoeven wrote:
> Hi Niklas,
> 
> I just got a flood of messages after WoL from s2idle on r8a7795/salvator-x:
> 
> [  802.341060] ravb e6800000.ethernet eth0: ignoring interrupt, rx
> status 0x00000001, rx mask 0x00000001,
> [  802.350369] ravb e6800000.ethernet eth0:                     tx
> status 0x00000000, tx mask 0x00000001.
> [  802.359684] ravb e6800000.ethernet eth0: ignoring interrupt, rx
> status 0x00000001, rx mask 0x00000001,
> [  802.368993] ravb e6800000.ethernet eth0:                     tx
> status 0x00000000, tx mask 0x00000001.
> [  802.378308] ravb e6800000.ethernet eth0: ignoring interrupt, rx
> status 0x00000001, rx mask 0x00000001,
> [  802.387616] ravb e6800000.ethernet eth0:                     tx
> status 0x00000000, tx mask 0x00000001.
> [  802.396931] ravb e6800000.ethernet eth0: ignoring interrupt, rx
> status 0x00000001, rx mask 0x00000001,
> [  802.406240] ravb e6800000.ethernet eth0:                     tx
> status 0x00000000, tx mask 0x00000001.
> ...
> 
> Unfortunately I cannot reproduce it.
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds

-- 
Regards,
Niklas Söderlund
