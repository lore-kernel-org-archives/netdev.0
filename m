From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH] tg3: Avoid NULL pointer dereference in tg3_get_nstats()
Date: Thu, 5 Jan 2017 13:53:05 -0800
Message-ID: <CACKFLi=KN6Fd6Wv7-vLPAAi3c6SyWdzg5BsFL+7WN_s-udQwaA@mail.gmail.com>
References: <1483625601-10552-1-git-send-email-wangyufen@huawei.com>
 <20170105.123337.2237827308340782208.davem@davemloft.net> <CACKFLimPkD6hxECA+ZhH+7BVmVSoJ1GfAMZyJ7S50CbhiuC0mA@mail.gmail.com>
 <20170105.151705.2187713228201334532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: wangyufen@huawei.com, Siva Reddy Kallam <siva.kallam@broadcom.com>,
        "prashant.sreedharan@broadcom.com" <prashant@broadcom.com>,
        "michael.chan@broadcom.com" <mchan@broadcom.com>,
        Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35753 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760807AbdAEVxG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 16:53:06 -0500
Received: by mail-oi0-f53.google.com with SMTP id b126so596436720oia.2
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 13:53:06 -0800 (PST)
In-Reply-To: <20170105.151705.2187713228201334532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 5, 2017 at 12:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Michael Chan <michael.chan@broadcom.com>
> Date: Thu, 5 Jan 2017 12:04:13 -0800
>
>> But it looks like ndo_get_stats() can be called without rtnl lock from
>> net-procfs.c.  So it is possible that we'll read tp->hw_stats after it
>> has been freed.  For example, if we are reading /proc/net/dev and
>> closing tg3 at the same time.  David, is not taking rtnl_lock in
>> net-procfs.c by design?
>
> Probably not, that dev_get_stats() call probably should be surrounded
> by RTNL protection.
>
> Doing a quick grep on dev_get_stats() shows other call sites, most of
> which are using it to fetch slave device statistics from the get stats
> method of the parent.  Which should be ok.
>
> It appears that the vlan procfs code in net/8021q/vlanproc.c has a
> similar bug as net/core/net-procfs.c
>
> Maybe net/core/net-sysfs.c has the same issue as well, and perhaps also
> net/openvswitch/vport.c:ovs_vport_get_stats().
>

OK.  I will send a patch later today to add rtnl_lock to these callers.
