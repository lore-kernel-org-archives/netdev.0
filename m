From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [QUESTION] poor TX performance on new GbE driver
Date: Sun, 22 Oct 2017 12:38:59 -0700
Message-ID: <1508701139.30291.64.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAKv+Gu_jDKrY8+DM_p9Ri6vuSv1Puddk0pkP=hzSy+1P_9Z18Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:54103 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751496AbdJVTjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 15:39:01 -0400
Received: by mail-pf0-f195.google.com with SMTP id t188so15552821pfd.10
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 12:39:01 -0700 (PDT)
In-Reply-To: <CAKv+Gu_jDKrY8+DM_p9Ri6vuSv1Puddk0pkP=hzSy+1P_9Z18Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-10-22 at 20:14 +0100, Ard Biesheuvel wrote:
> Hello all,
> 
> I am working on upstreaming a network driver for a Socionext SoC, and
> I am having some trouble figuring out why my TX performance is
> horrible when booting a Debian Stretch rootfs, while booting a Ubuntu
> 17.04 rootfs works absolutely fine. Note that this is using the exact
> same kernel image, booted off the network.
> 
> Under Ubuntu, I get the following iperf results from the box to my AMD
> Seattle based devbox with a 1 Gbit switch in between. (The NIC in
> question is also 1 Gbit)
> 
> 
> $ sudo iperf -c dogfood.local -r
> ------------------------------------------------------------
> Server listening on TCP port 5001
> TCP window size: 85.3 KByte (default)
> ------------------------------------------------------------
> ------------------------------------------------------------
> Client connecting to dogfood.local, TCP port 5001
> TCP window size:  748 KByte (default)
> ------------------------------------------------------------
> [  5] local 192.168.1.112 port 51666 connected with 192.168.1.106 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  5]  0.0-10.0 sec  1.07 GBytes   920 Mbits/sec
> [  4] local 192.168.1.112 port 5001 connected with 192.168.1.106 port 33048
> [  4]  0.0-10.0 sec  1.10 GBytes   940 Mbits/sec
> 
> Booting the *exact* same kernel into a Debian based rootfs results in
> the following numbers
> $ sudo iperf -c dogfood.local -r
> ------------------------------------------------------------
> Server listening on TCP port 5001
> TCP window size: 85.3 KByte (default)
> ------------------------------------------------------------
> ------------------------------------------------------------
> Client connecting to dogfood.local, TCP port 5001
> TCP window size: 85.0 KByte (default)
> ------------------------------------------------------------
> [  5] local 192.168.1.112 port 40132 connected with 192.168.1.106 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  5]  0.0-10.1 sec  4.12 MBytes  3.43 Mbits/sec
> [  4] local 192.168.1.112 port 5001 connected with 192.168.1.106 port 33068
> [  4]  0.0-10.0 sec  1.10 GBytes   939 Mbits/sec
> 
> The ifconfig stats look perfectly fine to me (TX errors 0  dropped 0
> overruns 0  carrier 0  collisions 0). During the TX test, the CPUs are
> almost completely idle. (This system has 24 cores, but not
> particularly powerful ones.)
> 
> This test is based on v4.14-rc4, but v4.13 gives the same results.
> 
> Could anyone please shed a light on this? What tuning parameters
> and/or stats should I be looking at? I am a seasoned kernel developer
> but a newbie when it comes to networking, so hopefully I just need a
> nudge to go looking in the right place.


This description smells a problem with TX completions being deferred.

TX interrupts being lost or deferred too much.
