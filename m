From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Wed, 21 Sep 2016 11:09:37 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1609211038200.5573@nanos>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org> <20160920202556.GA6713@localhost.localdomain> <20160920204556.GA7555@localhost.localdomain> <alpine.LFD.2.20.1609201655200.9311@knanqh.ubzr> <alpine.DEB.2.20.1609202300140.5476@nanos>
 <alpine.LFD.2.20.1609201833010.9311@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Richard Cochran <richardcochran@gmail.com>,
        John Stultz <john.stultz@linaro.org>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:33780 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751167AbcIUJMD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 05:12:03 -0400
In-Reply-To: <alpine.LFD.2.20.1609201833010.9311@knanqh.ubzr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016, Nicolas Pitre wrote:
> There are way more drivers than subsystems and if you had to go around 
> unselecting all NIC drivers for CONFIG_ETHERNET to be turned off, and 
> with CONFIG_ETHERNET=n you'd finally be able to turn networking off, 
> then this would be a nightmare.

It's also a nightmare to try to enable something which depends on a chain
of config dependencies. You search A and see that it depends on B. Now you
try to enable B and find out it depends on C. The deepest chain I found so
far was 5 levels deep. That's horrible.

> IMHO it is much nicer for the poor user configuring the kernel to have a 
> single configuration prompt for PTP support, and then have whatever 
> driver that can provide a PTP clock just do it (or omit it) based on 
> that single prompt.  Prompting for PTP support for each individual 
> ethernet driver is silly.

No, it's not. PTP support in a NIC can require a substantial amount of code
and adds overhead in the hotpath. So if you have two NICs on your system
and only use PTP on one of them then configuring out PTP for the other is
desired.

And talking about nightmares. With your patch I can now end up with the
following configuration:

    CONFIG_NETWORK_DRIVER=y
    CONFIG_PTP_1588_CLOCK=m

which makes the network driver to use the stub functions due to
IS_REACHABLE(). That's going to be an utter nightmare for the poor user to
figure out why PTP suddenly does not work anymore. That's simply crap.

Thanks,

	tglx
