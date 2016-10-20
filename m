From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Thu, 20 Oct 2016 12:17:18 +0200
Message-ID: <eced0989-d8bc-d34e-9ecb-8540d80a7173@6wind.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: sds@tycho.nsa.gov, e@eladraz.com, paul@paul-moore.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:35126 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752796AbcJTKRY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 06:17:24 -0400
Received: by mail-lf0-f52.google.com with SMTP id l131so71968481lfl.2
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 03:17:23 -0700 (PDT)
In-Reply-To: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/10/2016 à 08:52, Cong Wang a écrit :
> A kernel warning inside __local_bh_enable_ip() was reported by people
> running SELinux, this is caused due to some SELinux functions
> (indirectly) call peernet2id() with IRQ disabled in process context,
> when we re-enable BH with IRQ disabled kernel complains. Shut up this
> warning by saving IRQ context in peernet2id(), BH is still implicitly
> disabled.

Franckly, reverting the original patch seems better for me. The intention for
that patch was "it's not needed", see the commit log:

"We never read or change netns id in hardirq context,
the only place we read netns id in softirq context
is in vxlan_xmit(). So, it should be enough to just
disable BH."

Now, we see that "it's needed" and that the analysis was wrong. If a race is
introduced by this patch, it will be hard to detect and fix it.


Regards,
Nicolas
