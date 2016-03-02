From: David Ahern <dsahern@gmail.com>
Subject: Re: [net-next,v7] net: ipv6: Make address flushing on ifdown optional
Date: Wed, 2 Mar 2016 10:23:17 -0800
Message-ID: <56D72F95.3030101@gmail.com>
References: <CANaxB-z7JefW0hQ2cODX_JLOqWbpTM371E_SDpGXrmdtvS_UcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Andrey Wagin <avagin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35621 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932155AbcCBSXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:23:19 -0500
Received: by mail-pf0-f176.google.com with SMTP id w128so93730007pfb.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:23:19 -0800 (PST)
In-Reply-To: <CANaxB-z7JefW0hQ2cODX_JLOqWbpTM371E_SDpGXrmdtvS_UcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/16 10:01 AM, Andrey Wagin wrote:
> Hi David,
>
> We execute CRIU test on linux-next. On the current linux-next kernel
> they hangs on creating a network namespace.
>
> The kernel log contains many massages like this:
> [ 1036.122108] unregister_netdevice: waiting for lo to become free.
> Usage count = 2
> [ 1046.165156] unregister_netdevice: waiting for lo to become free.
> Usage count = 2
> [ 1056.210287] unregister_netdevice: waiting for lo to become free.
> Usage count = 2
>
> I tried to revert this patch and the bug disappeared.
>
> Here is a set of commands to reproduce this bug:
>
> [root@linux-next-test linux-next]# uname -a
> Linux linux-next-test 4.5.0-rc6-next-20160301+ #3 SMP Wed Mar 2
> 17:32:18 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
>
> [root@linux-next-test ~]# unshare -n
> [root@linux-next-test ~]# ip link set up dev lo
> [root@linux-next-test ~]# ip a
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
> group default qlen 1
>      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>      inet 127.0.0.1/8 scope host lo
>         valid_lft forever preferred_lft forever
>      inet6 ::1/128 scope host
>         valid_lft forever preferred_lft forever
> [root@linux-next-test ~]# logout
> [root@linux-next-test ~]# unshare -n

Thanks for reporting -- with reproduction commands. I will post patch as 
soon as I have time to look into it.

David
