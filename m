From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net_sched: hold tcf_lock in netdevice notifier
Date: Fri, 18 Jul 2014 07:37:03 +0200
Message-ID: <1405661823.10255.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1405545931-13832-2-git-send-email-xiyou.wangcong@gmail.com>
	 <53C7C675.7090400@mojatatu.com>
	 <CAM_iQpU6=rtb+-T9NiiEJ+799PtJo=j1=EBuAL76Ac7=w=MKHA@mail.gmail.com>
	 <1405621030.10255.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpUgDurOWfXHdx_aTBS2L0h1QWUFe-du3W6CsZw8jfaF7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:51332 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbaGRFhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 01:37:08 -0400
Received: by mail-wg0-f41.google.com with SMTP id z12so3024501wgg.24
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 22:37:07 -0700 (PDT)
In-Reply-To: <CAM_iQpUgDurOWfXHdx_aTBS2L0h1QWUFe-du3W6CsZw8jfaF7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 14:25 -0700, Cong Wang wrote:
> On Thu, Jul 17, 2014 at 11:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Anyway, tcfm_dev should probably be RCU protected.
> >
> 
> Not sure how much we gain from making it RCU. We anyway
> need to hold that spinlock on fast path since we need to
> update its time stamp and stats.
> 
> I would just leave it as is.


I think you really should look at John Fastabend work, and many other
existing paths in the stack.

All this can be done lockless in fast path, using RCU and percpu
counters.
