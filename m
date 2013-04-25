From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 3/5] sock_diag: allow to dump bpf filters
Date: Thu, 25 Apr 2013 10:37:00 +0200
Message-ID: <5178EB2C.6070709@6wind.com>
References: <51779426.7020800@6wind.com>  <1366818756-4234-1-git-send-email-nicolas.dichtel@6wind.com>  <1366818756-4234-4-git-send-email-nicolas.dichtel@6wind.com> <1366820565.8964.78.camel@edumazet-glaptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:38530 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122Ab3DYIhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:37:05 -0400
Received: by mail-we0-f178.google.com with SMTP id z53so2471418wey.9
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 01:37:03 -0700 (PDT)
In-Reply-To: <1366820565.8964.78.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/04/2013 18:22, Eric Dumazet a =C3=A9crit :
> On Wed, 2013-04-24 at 17:52 +0200, Nicolas Dichtel wrote:
>> This patch allows to dump BPF filters attached to a socket with
>> SO_ATTACH_FILTER. In other words, users allowing to open netlink soc=
kets can
>> see filters set on a socket (when the diag module of the socket fami=
ly is
>> loaded).
>
> To my knowledge, opening netlink sockets is not restricted.
>
> I do not want user lambda being able to see my BPF filters.
>
> I am root, and was assuming user lambda could not spy on me.
>
> $ cat /proc/net/packet
> sk       RefCnt Type Proto  Iface R Rmem   User   Inode
> 0000000000000000 3      10   0003   3     1 0      0      1089989
> 0000000000000000 3      10   0003   2     1 0      0      1050535
> 0000000000000000 3      2    888e   3     1 0      0      1041970
>
>
> With this information, it seems safe enough, but the whole BPF could
> give interesting ideas to user lambda.
I agree. But then you just have to avoid loading the module packet_diag=
=2E This=20
module already give some clue to users, because it sends the socket poi=
nter=20
through netlink.
Maybe I'm wrong, but I was thinking that this module is used for debug =
purpose.
If the module is not loaded, my patch has no effect on the system.
