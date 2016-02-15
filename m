From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: IPv4/IPv6 sysctl defaults in new namespace
Date: Mon, 15 Feb 2016 13:49:18 +0300
Message-ID: <CALYGNiNJ=LCyo4v7B1BUZH-27bc22ap-RQKpPQN7m0V3kBjkPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vasily Averin <vvs@virtuozzo.com>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37611 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbcBOKtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 05:49:19 -0500
Received: by mail-wm0-f48.google.com with SMTP id g62so102947582wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 02:49:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 initialized with default. That's ok.
IPv4 makes a copy from init_net. Looks like a bug, here
v2.6.24-2577-g752d14dc6aa9

root@zurg:~# sysctl net.ipv4.conf.all.forwarding=0
net.ipv6.conf.all.forwarding=0
net.ipv4.conf.all.forwarding = 0
net.ipv6.conf.all.forwarding = 0
root@zurg:~# unshare -n sysctl net.ipv4.conf.all.forwarding
net.ipv6.conf.all.forwarding
net.ipv4.conf.all.forwarding = 0
net.ipv6.conf.all.forwarding = 0
root@zurg:~# sysctl net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
root@zurg:~# unshare -n sysctl net.ipv4.conf.all.forwarding
net.ipv6.conf.all.forwarding
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 0

This is nasty. Could we fix this or this bug set in stone?
