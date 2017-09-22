From: =?UTF-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next 1/2] dummy: add device MTU validation check
Date: Fri, 22 Sep 2017 20:59:39 +0800
Message-ID: <000801d333a2$a7666320$f6332960$@cmss.chinamobile.com>
References: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com> <1506000722-40095-2-git-send-email-zhangshengju@cmss.chinamobile.com> <1506006138.29839.132.camel@edumazet-glaptop3.roam.corp.google.com> <20170922085610.GA4544@bistromath.localdomain> <1506078309.29839.161.camel@edumazet-glaptop3.roam.corp.google.com> <20170922122315.GA3446@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "'Jarod Wilson'" <jarod@redhat.com>, <davem@davemloft.net>,
        <willemb@google.com>, <stephen@networkplumber.org>,
        <netdev@vger.kernel.org>
To: "'Sabrina Dubroca'" <sd@queasysnail.net>,
        "'Eric Dumazet'" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:12410 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751851AbdIVM7t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 08:59:49 -0400
In-Reply-To: <20170922122315.GA3446@bistromath.localdomain>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sabrina Dubroca [mailto:sd@queasysnail.net]
> Sent: 2017年9月22日 20:23
> To: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jarod Wilson <jarod@redhat.com>; Zhang Shengju
> <zhangshengju@cmss.chinamobile.com>; davem@davemloft.net;
> willemb@google.com; stephen@networkplumber.org;
> netdev@vger.kernel.org
> Subject: Re: [net-next 1/2] dummy: add device MTU validation check
> 
> 2017-09-22, 04:05:09 -0700, Eric Dumazet wrote:
> > On Fri, 2017-09-22 at 10:56 +0200, Sabrina Dubroca wrote:
> > > 2017-09-21, 08:02:18 -0700, Eric Dumazet wrote:
> > > > On Thu, 2017-09-21 at 21:32 +0800, Zhang Shengju wrote:
> > > > > Currently, any mtu value can be assigned when adding a new dummy
> device:
> > > > > [~]# ip link add name dummy1 mtu 100000 type dummy [~]# ip link
> > > > > show dummy1
> > > > > 15: dummy1: <BROADCAST,NOARP> mtu 100000 qdisc noop state
> DOWN mode DEFAULT group default qlen 1000
> > > > >     link/ether 0a:61:6b:16:14:ce brd ff:ff:ff:ff:ff:ff
> > > > >
> > > > > This patch adds device MTU validation check.
> > > >
> > > > What is wrong with big MTU on dummy ?
> > >
> > > It looks like the "centralize MTU checking" series broke that, but
> > > only for changing the MTU on an existing dummy device. Commit
> > > a52ad514fdf3 defined min_mtu/max_mtu in ether_setup, which dummy
> > > uses, but there was no MTU check in dummy prior to that commit.
> > >
> >
> > It looks like we accept big mtu on loopback, right ?
> 
> Yes. I only meant that before commit a52ad514fdf3, there was no range check
> on dummy's MTU. Commit 25e3e84b183a ("dummy: expend mtu range for
> dummy device") and 8b1efc0f83f1 ("net: remove MTU limits on a few
> ether_setup callers") fixed that only partially. It's the same with ifb, btw, it
> didn't have any check before a52ad514fdf3, so we should set min_mtu =
> max_mtu = 0.
> 
> --
> Sabrina

I agree, dummy and ifb device should not have any limit on mtu, just like loopback device.
I will send v2 patch, and set min/max_mtu to zero for dummy and ifb device, thanks.

ZSJ
