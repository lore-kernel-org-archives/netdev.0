From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Sat, 26 Nov 2016 18:16:00 -0800
Message-ID: <1480212960.18162.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8nFBFy=-pjy-XBYb-y-F=grC5wjN35zTt9eUOT-612Eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35462 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752505AbcK0CQD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 21:16:03 -0500
Received: by mail-pf0-f194.google.com with SMTP id i88so4562432pfk.2
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 18:16:03 -0800 (PST)
In-Reply-To: <CALzJLG8nFBFy=-pjy-XBYb-y-F=grC5wjN35zTt9eUOT-612Eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-11-27 at 00:47 +0200, Saeed Mahameed wrote:
> On Fri, Nov 25, 2016 at 5:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> As you see here in SRIOV mode (PF only) reads   sw stats from FW.
> Tariq, I think we need to fix this.

Sure, my patch does not change this at all.

If mlx4_is_master() is false, then we aggregate the software states and
only the software stats.

My patch makes this aggregation possible at the time ethtool or
ndo_get_stat64() are called, since this absolutely not depend on the 250
ms timer fetching hardware stats.
