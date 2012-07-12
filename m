From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: [PATCH v2] netns: correctly use per-netns ipv4 sysctl_tcp_mem
Date: Thu, 12 Jul 2012 19:17:18 +0800
Message-ID: <CAF1ivSbYF=wYaPR3XQOZZ_KcvAVYdnU0=deDaCYMLTnhoJ3OZw@mail.gmail.com>
References: <4FFE99EE.70003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, glommer@parallels.com,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	yangzhenzhang@huawei.com
To: Huang Qiang <h.huangqiang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:42039 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S932198Ab2GLLSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 07:18:08 -0400
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 0E556DBC37
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 19:17:21 +0800 (CST)
Received: by vcbf11 with SMTP id f11so1403097vcb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 04:17:18 -0700 (PDT)
In-Reply-To: <4FFE99EE.70003@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 5:33 PM, Huang Qiang <h.huangqiang@huawei.com> wrote:
> From: Yang Zhenzhang <yangzhenzhang@huawei.com>
>
> Now, kernel allows each net namespace to independently set up its levels
> for tcp memory pressure thresholds.
>
> But it seems there is a bug, as using the following steps:
>
> [root@host socket]# lxc-start -n test -f config /bin/bash
> [root@net-test socket]# ip route add default via 192.168.58.2
> [root@net-test socket]# echo 0 0 0 > /proc/sys/net/ipv4/tcp_mem
> [root@net-test socket]# scp root@192.168.58.174:/home/tcp_mem_test .
>
> and it still can transport the "tcp_mem_test" file which we hope it
> would not.
>
> It's because inet_init() (net/ipv4/af_inet.c)initialize the tcp_prot.sysctl_mem:
> tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
>
> So when the protocal is TCP, sk->sk_prot->sysctl_mem(following code)

s/protocal/protocol/

> always use the ipv4 sysctl_tcp_mem of init_net namespace rather than
> it's own net namespace.
> This patch simply set "prot" equal to net->ipv4.sysctl_tcp_mem when
> the protocol type is TCP.
>
> Signed-off-by: Yang Zhenzhang <yangzhenzhang@huawei.com>
> Signed-off-by: Huang Qiang <h.huangqiang@huawei.com>
