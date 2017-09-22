From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [net-next 1/2] dummy: add device MTU validation check
Date: Fri, 22 Sep 2017 14:23:15 +0200
Message-ID: <20170922122315.GA3446@bistromath.localdomain>
References: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <1506000722-40095-2-git-send-email-zhangshengju@cmss.chinamobile.com>
 <1506006138.29839.132.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170922085610.GA4544@bistromath.localdomain>
 <1506078309.29839.161.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jarod Wilson <jarod@redhat.com>,
        Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        davem@davemloft.net, willemb@google.com,
        stephen@networkplumber.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32640 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752039AbdIVMXW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 08:23:22 -0400
Content-Disposition: inline
In-Reply-To: <1506078309.29839.161.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-09-22, 04:05:09 -0700, Eric Dumazet wrote:
> On Fri, 2017-09-22 at 10:56 +0200, Sabrina Dubroca wrote:
> > 2017-09-21, 08:02:18 -0700, Eric Dumazet wrote:
> > > On Thu, 2017-09-21 at 21:32 +0800, Zhang Shengju wrote:
> > > > Currently, any mtu value can be assigned when adding a new dummy device:
> > > > [~]# ip link add name dummy1 mtu 100000 type dummy
> > > > [~]# ip link show dummy1
> > > > 15: dummy1: <BROADCAST,NOARP> mtu 100000 qdisc noop state DOWN mode DEFAULT group default qlen 1000
> > > >     link/ether 0a:61:6b:16:14:ce brd ff:ff:ff:ff:ff:ff
> > > > 
> > > > This patch adds device MTU validation check.
> > > 
> > > What is wrong with big MTU on dummy ?
> > 
> > It looks like the "centralize MTU checking" series broke that, but
> > only for changing the MTU on an existing dummy device. Commit
> > a52ad514fdf3 defined min_mtu/max_mtu in ether_setup, which dummy uses,
> > but there was no MTU check in dummy prior to that commit.
> > 
> 
> It looks like we accept big mtu on loopback, right ?

Yes. I only meant that before commit a52ad514fdf3, there was no range
check on dummy's MTU. Commit 25e3e84b183a ("dummy: expend mtu range
for dummy device") and 8b1efc0f83f1 ("net: remove MTU limits on a few
ether_setup callers") fixed that only partially. It's the same with
ifb, btw, it didn't have any check before a52ad514fdf3, so we should
set min_mtu = max_mtu = 0.

-- 
Sabrina
