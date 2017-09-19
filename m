From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of
 net/ipv4/tcp_input.c
Date: Tue, 19 Sep 2017 13:04:10 +0200
Message-ID: <13e86265b8db3a5b1f1eaf8135ff4510@natalenko.name>
References: <10035198.1vE6NFrMDO@natalenko.name>
 <40697505.YK5nrFG7Le@natalenko.name>
 <CAK6E8=djbT-35JuHq+hhOKOG+BEO3RCwgsVPoKcDhNBph5OezA@mail.gmail.com>
 <2149381.XGPd7soC9e@natalenko.name>
 <CAK6E8=e7SE-M4r2nJ8K_FoDMVcN2xYdtw=MetvD5MvXMm9iA1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Cc: Neal Cardwell <ncardwell@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vulcan.natalenko.name ([104.207.131.136]:42926 "EHLO
        vulcan.natalenko.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751394AbdISLEM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 07:04:12 -0400
In-Reply-To: <CAK6E8=e7SE-M4r2nJ8K_FoDMVcN2xYdtw=MetvD5MvXMm9iA1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

18.09.2017 23:40, Yuchung Cheng wrote:
> I assume this kernel does not have the patch that Neal proposed in his
> first reply?

Correct.

> The main warning needs to be triggered by another peculiar SACK that
> kicks the sender into recovery again (after undo). Please let it run
> longer if possible to see if we can get both. But the new data does
> indicate the we can (validly) be in CA_Open with retrans_out > 0.

OK, here it is:

===
» LC_TIME=C jctl -kb | grep RIP
…
Sep 19 12:54:03 defiant kernel: RIP: 
0010:tcp_undo_cwnd_reduction+0xbd/0xd0
Sep 19 12:54:22 defiant kernel: RIP: 
0010:tcp_undo_cwnd_reduction+0xbd/0xd0
Sep 19 12:54:25 defiant kernel: RIP: 
0010:tcp_undo_cwnd_reduction+0xbd/0xd0
Sep 19 12:56:00 defiant kernel: RIP: 
0010:tcp_fastretrans_alert+0x7c8/0x990
Sep 19 12:57:07 defiant kernel: RIP: 
0010:tcp_undo_cwnd_reduction+0xbd/0xd0
Sep 19 12:57:14 defiant kernel: RIP: 
0010:tcp_undo_cwnd_reduction+0xbd/0xd0
Sep 19 12:58:04 defiant kernel: RIP: 
0010:tcp_undo_cwnd_reduction+0xbd/0xd0
…
===

Note timestamps — two types of warning are distant in time, so didn't 
happen at once.

While still running this kernel, anything else I can check for you?
