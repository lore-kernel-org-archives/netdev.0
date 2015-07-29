From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: restore "mpu xxx" handling
Date: Wed, 29 Jul 2015 15:04:28 +0200
Message-ID: <1438175068.20182.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <55B8B807.4030102@odin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, tkhai@ya.ru
To: Kirill Tkhai <ktkhai@odin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33318 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbG2NEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 09:04:32 -0400
Received: by wicmv11 with SMTP id mv11so218285828wic.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 06:04:31 -0700 (PDT)
In-Reply-To: <55B8B807.4030102@odin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-29 at 14:24 +0300, Kirill Tkhai wrote:
> commit 56b765b79 ("htb: improved accuracy at high rates")
> broke the "mpu xxx" handling.
> 
> This patch restores the "mpu xxx" handling for htb:
> 
> # tc class add dev eth0 classid 1:2 parent 1: htb rate 1mbit mpu 0
> # ping -f -c 1000 10.30.22.52
> rtt min/avg/max/mdev = 0.156/1.881/2.454/0.175 ms, ipg/ewma 1.908/1.925 ms
> 
> # tc class change dev eth0 classid 1:2 parent 1: htb rate 1mbit mpu 1000
> # ping -f -c 1000 10.30.22.52
> rtt min/avg/max/mdev = 15.352/22.229/38.646/2.212 ms, pipe 3, ipg/ewma 15.999/22.609 ms

Note this mpu option was completely broken a long time ago with GSO /
TSO anyway.

Note sure we really want it in this state ?

What is your use case ?

In any case, correct fix would be in psched_l2t_ns(), otherwise you fix
htb but not the other qdisc (tbf for that matter)
