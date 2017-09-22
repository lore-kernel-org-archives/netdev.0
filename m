From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 1/2] dummy: add device MTU validation check
Date: Fri, 22 Sep 2017 04:05:09 -0700
Message-ID: <1506078309.29839.161.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>
         <1506000722-40095-2-git-send-email-zhangshengju@cmss.chinamobile.com>
         <1506006138.29839.132.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170922085610.GA4544@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarod Wilson <jarod@redhat.com>,
        Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        davem@davemloft.net, willemb@google.com,
        stephen@networkplumber.org, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32856 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751919AbdIVLFN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 07:05:13 -0400
Received: by mail-io0-f196.google.com with SMTP id j26so1192920iod.0
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 04:05:12 -0700 (PDT)
In-Reply-To: <20170922085610.GA4544@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-22 at 10:56 +0200, Sabrina Dubroca wrote:
> 2017-09-21, 08:02:18 -0700, Eric Dumazet wrote:
> > On Thu, 2017-09-21 at 21:32 +0800, Zhang Shengju wrote:
> > > Currently, any mtu value can be assigned when adding a new dummy device:
> > > [~]# ip link add name dummy1 mtu 100000 type dummy
> > > [~]# ip link show dummy1
> > > 15: dummy1: <BROADCAST,NOARP> mtu 100000 qdisc noop state DOWN mode DEFAULT group default qlen 1000
> > >     link/ether 0a:61:6b:16:14:ce brd ff:ff:ff:ff:ff:ff
> > > 
> > > This patch adds device MTU validation check.
> > 
> > What is wrong with big MTU on dummy ?
> 
> It looks like the "centralize MTU checking" series broke that, but
> only for changing the MTU on an existing dummy device. Commit
> a52ad514fdf3 defined min_mtu/max_mtu in ether_setup, which dummy uses,
> but there was no MTU check in dummy prior to that commit.
> 

It looks like we accept big mtu on loopback, right ?

lpaa23:~# ifconfig lo mtu 100000
lpaa23:~# ifconfig lo
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:100000  Metric:1
          RX packets:3823 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3823 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:759159 (759.1 KB)  TX bytes:759159 (759.1 KB)

Also we accept very small MTU as well (although this automatically
removes IP addresses, as one would expect)

lpaa23:~# ifconfig lo mtu 50
lpaa23:~# ifconfig lo
lo        Link encap:Local Loopback  
          UP LOOPBACK RUNNING  MTU:50  Metric:1
          RX packets:4052 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4052 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:806274 (806.2 KB)  TX bytes:806274 (806.2 KB)



So, why dummy devices would not accept bit MTU ?

Do we have some fundamental assumption in the stack ?

If yes, we need to fix loopback urgently, it is more important than
dummy.

Thanks.
