From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/dccp: use-after-free in dccp_feat_activate_values
Date: Fri, 03 Mar 2017 07:13:04 -0800
Message-ID: <1488553984.9415.332.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+xDhUDe9_-uEakJG9iqTtD_+fFr+JyUbkWCHHLBCcu1uQ@mail.gmail.com>
         <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
         <CACT4Y+YUJGsvzFuFT3r0M-3KbPrcx62fzSHHQX=B43-syLYU0A@mail.gmail.com>
         <1488551576.9415.328.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488552503.9415.330.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+Z6t_jGoh3Gm3Sxuu_ugF5kQ3QJ37LVdqoEK_ab52tQMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35714 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751870AbdCCPUg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 10:20:36 -0500
In-Reply-To: <CACT4Y+Z6t_jGoh3Gm3Sxuu_ugF5kQ3QJ37LVdqoEK_ab52tQMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-03 at 16:06 +0100, Dmitry Vyukov wrote:

> Something that compiles is definitely better :)
> Reapplied.

Just to be clear : This is not the proper patch. This only reduces the
race.

bh_lock_sock() does not prevent a user process from owning the socket.

We need another protection, probably RCU based, or another spinlock
protecting the fields needed at SYNACK generation.
