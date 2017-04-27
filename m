From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] ipv4: get rid of ip_ra_lock
Date: Thu, 27 Apr 2017 16:54:17 -0700
Message-ID: <1493337257.31837.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493240115-779-1-git-send-email-xiyou.wangcong@gmail.com>
         <1493297179.6453.105.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXexP9OzzqyPJ-yHmyq-ZF=cNboaG8566yaxZKbn0+TTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35106 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968256AbdD0XyS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 19:54:18 -0400
Received: by mail-pf0-f195.google.com with SMTP id i4so1227250pfc.2
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 16:54:18 -0700 (PDT)
In-Reply-To: <CAM_iQpXexP9OzzqyPJ-yHmyq-ZF=cNboaG8566yaxZKbn0+TTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-27 at 16:46 -0700, Cong Wang wrote:
> On Thu, Apr 27, 2017 at 5:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2017-04-26 at 13:55 -0700, Cong Wang wrote:
> >> After commit 1215e51edad1 ("ipv4: fix a deadlock in ip_ra_control")
> >> we always take RTNL lock for ip_ra_control() which is the only place
> >> we update the list ip_ra_chain, so the ip_ra_lock is no longer needed,
> >> we just need to disable BH there.
> >>
> >> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> >> ---
> >
> > Looks great, but reading again this code, I believe we do not need to
> > disable BH at all ?
> >
> 
> Hmm, if we don't disable BH here, a reader in BH could jump in and
> break this critical section? Or that is fine for RCU?

It should be fine for RCU.

The spinlock (or mutex if this is RTNL) is protecting writers among
themselves. Here it should run in process context, with no specific
rules to disable preemption, hard or soft irqs.

The reader(s) do not care of how writer(s) enforce their mutual
protection, and if writer(s) disable hard or soft irqs.
