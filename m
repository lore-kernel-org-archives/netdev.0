From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Unexpected tcpv6 connection resets since linux 4.4
Date: Mon, 7 Mar 2016 15:58:47 -0800
Message-ID: <CAM_iQpXSu_uXCOCtw02EAaOVP_54a1G8pgZrDMTWFEGnSeycJQ@mail.gmail.com>
References: <4875526.tAzumr2zO3@proton>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andreas Messer <andi@bastelmap.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:34024 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933779AbcCGX6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 18:58:53 -0500
In-Reply-To: <4875526.tAzumr2zO3@proton>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc'ing netdev

On Sun, Mar 6, 2016 at 7:10 AM, Andreas Messer <andi@bastelmap.de> wrote:
> Hi there,
>
> i have updated two of my machines in the last weeks to linux 4.4.1 and linux
> 4.4.3. It seems that since then i get unexpected TCPv6 connection resets when
> connecting to these machines remotely. The issue occurs with sshd and with a
> http service. /etc/hosts.deny and /etc/hosts.allow are empty on both server
> machines. I'm not so in IPv6 and have no idea whats going on. Please find
> attached a network trace from one of the machines when connecting with ssh (on
> port 23 for debugging).

Sounds like the problem fixed by the following commit:

commit 9cf7490360bf2c46a16b7525f899e4970c5fc144
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Feb 2 19:31:12 2016 -0800

    tcp: do not drop syn_recv on all icmp reports


Thanks.


>
> Redirects should be accepted according to settings:
>
> root@banana:/proc/sys/net/ipv6# cat conf/wlan0/forwarding
> 0
> root@banana:/proc/sys/net/ipv6# cat conf/wlan0/accept_redirects
> 1
> root@banana:/proc/sys/net/ipv6# uname -a
> Linux banana 4.4.1-banana #3 SMP Wed Feb 17 23:03:38 CET 2016 x86_64 GNU/Linux
>
> Is there some new network settings or features? My network consists of an
> ethernet/wlan router where subnet of wlan and ethernet are identical.  (forced
> by the router, but was never a problem before). The problem occurs when
> connecting from ethernet machine to wlan machine and when connecting from wlan
> machine to wlan machine. At the moment its not possible to establish a
> connection with these machines using IPv6.
>
> Thanks for help!
>
> Cheers
> Andreas
