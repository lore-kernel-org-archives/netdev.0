From: Andrey Wagin <avagin@gmail.com>
Subject: Re: [net-next,v7] net: ipv6: Make address flushing on ifdown optional
Date: Wed, 2 Mar 2016 10:01:57 -0800
Message-ID: <CANaxB-z7JefW0hQ2cODX_JLOqWbpTM371E_SDpGXrmdtvS_UcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36362 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbcCBSB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:01:58 -0500
Received: by mail-lb0-f171.google.com with SMTP id x1so122753654lbj.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:01:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

We execute CRIU test on linux-next. On the current linux-next kernel
they hangs on creating a network namespace.

The kernel log contains many massages like this:
[ 1036.122108] unregister_netdevice: waiting for lo to become free.
Usage count = 2
[ 1046.165156] unregister_netdevice: waiting for lo to become free.
Usage count = 2
[ 1056.210287] unregister_netdevice: waiting for lo to become free.
Usage count = 2

I tried to revert this patch and the bug disappeared.

Here is a set of commands to reproduce this bug:

[root@linux-next-test linux-next]# uname -a
Linux linux-next-test 4.5.0-rc6-next-20160301+ #3 SMP Wed Mar 2
17:32:18 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

[root@linux-next-test ~]# unshare -n
[root@linux-next-test ~]# ip link set up dev lo
[root@linux-next-test ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
[root@linux-next-test ~]# logout
[root@linux-next-test ~]# unshare -n



^Z
...

Thanks,
Andrew
