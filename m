From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net_sched: hold tcf_lock in netdevice notifier
Date: Thu, 17 Jul 2014 20:17:10 +0200
Message-ID: <1405621030.10255.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1405545931-13832-2-git-send-email-xiyou.wangcong@gmail.com>
	 <53C7C675.7090400@mojatatu.com>
	 <CAM_iQpU6=rtb+-T9NiiEJ+799PtJo=j1=EBuAL76Ac7=w=MKHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38618 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbaGQSRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 14:17:15 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so8182376wiv.13
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 11:17:14 -0700 (PDT)
In-Reply-To: <CAM_iQpU6=rtb+-T9NiiEJ+799PtJo=j1=EBuAL76Ac7=w=MKHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 09:45 -0700, Cong Wang wrote:
> On Thu, Jul 17, 2014 at 5:49 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> > On 07/16/14 17:25, Cong Wang wrote:
> >>
> >> From: Cong Wang <cwang@twopensource.com>
> >>
> >> We modify mirred action (m->tcfm_dev) in netdev event, we need to
> >> prevent on-going mirred actions from reading freed m->tcfm_dev.
> >> So we need to acquire this spin lock.
> >>
> >
> > Cong,
> >
> > What setup prompted this? We have no problems dealing with deleted
> > devices in the data path. It seems harmless otherwise.
> >
> 
> 
> I found this during code review, don't see any real crash. This
> is why I sent it for net-next not net. :)
> 
> The reason why it doesn't trigger a crash is I think dev_put()
> doesn't immediately release dev when refcount hits zero,
> instead it defers that to rtnl_unlock().

There is no way this dev_put() could make refcnt reaching 0, unless
there is a serious bug elsewhere.

Anyway, tcfm_dev should probably be RCU protected.
