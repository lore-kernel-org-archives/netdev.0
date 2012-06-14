From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 16:29:17 +0200
Message-ID: <1339684157.22704.722.camel@edumazet-glaptop>
References: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
	 <1339665719.22704.692.camel@edumazet-glaptop>
	 <1339667417.22704.707.camel@edumazet-glaptop>
	 <CAL8zT=icffEiz9MeaNwMtzteQnXiaT4k++s0TPWt5zsnHxFbmw@mail.gmail.com>
	 <CAL8zT=huqtqBKzH3DDwid_C8jH16SH=kjYEK6zjxp_spfnLxXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60968 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755905Ab2FNO3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 10:29:22 -0400
Received: by eaak11 with SMTP id k11so595060eaa.19
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 07:29:21 -0700 (PDT)
In-Reply-To: <CAL8zT=huqtqBKzH3DDwid_C8jH16SH=kjYEK6zjxp_spfnLxXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-14 at 16:14 +0200, Jean-Michel Hautbois wrote:

> ~# tc -s -d qdisc show dev eth1 > before_tc && sleep 10 && tc -s -d
> qdisc show dev eth1 > after_tc && ./beforeafter before_tc after_tc
> qdisc mq 0: root
>  Sent 3185900568 bytes 788681 pkt (dropped 0, overlimits 0 requeues 620)
>  backlog 0b 0p requeues 620
> 
> As you can see, 2.5Gbps without any difficulties :).
> 
> Thanks,
> JM

I have no idea why throughput on ethernet link is changed.

There is another bug elsewhere.  Use a thousand of sockets instead of
few, and you'll hit the bug.

Orphaning skbs should not lower speed of the device, only drops excess
packets, instead of blocking the application, waiting the socket wmem
alloc being freed by destructors.

Are you playing with process priorities ?

If the ksoftirqd cannot run, this could explain the problem.
