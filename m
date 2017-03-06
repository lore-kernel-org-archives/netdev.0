From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [4.9.13] use after free in ipv4_mtu
Date: Mon, 06 Mar 2017 08:20:03 -0800
Message-ID: <1488817203.9415.382.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAMVG2ssDe2NMOZzeTF77H1zEEh3dBuT75bS6f81Tqd+3v_4J+g@mail.gmail.com>
         <1488460104.9415.325.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488461281.9415.327.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAMVG2styKvhUkVnhkFJ-B427sgnbxsBN8rJfE=wFd3wtXYXvrg@mail.gmail.com>
         <1488807904.9415.375.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <shemminger@linux-foundation.org>
To: Daniel J Blueman <daniel@quora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34531 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753256AbdCFQ2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 11:28:04 -0500
Received: by mail-pg0-f67.google.com with SMTP id b5so3356218pgg.1
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 08:27:25 -0800 (PST)
In-Reply-To: <1488807904.9415.375.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-06 at 05:45 -0800, Eric Dumazet wrote:
> On Mon, 2017-03-06 at 14:33 +0800, Daniel J Blueman wrote:

> > I do change the network queueing discipline and related at runtime [1]
> > which may be triggering this, though I did think I saw the KASAN
> > report only after resuming from suspend. rf(un)kill and other tweaking
> > may have been involved too.
> > 
> > Thanks,
> >   Dan
> > 
> > [1] /etc/sysctl.d/90-tcp.conf
> > 
> > net.core.default_qdisc = fq_codel
> > net.ipv4.tcp_congestion_control = bbr
> > net.ipv4.tcp_slow_start_after_idle = 0
> > net.ipv4.tcp_ecn = 1

BTW, fq_codel is not suitable for BBR.

Only fq contains the needed pacing for BBR.
