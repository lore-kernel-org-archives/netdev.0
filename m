From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 12:22:51 +0800
Message-ID: <p2t412e6f7f1004142122w115b2855o3880467da5cc1e2d@mail.gmail.com>
References: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
	<1271302133.16881.1814.camel@edumazet-laptop> <1271302846.16881.1828.camel@edumazet-laptop>
	<1271304846.16881.1881.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.211.194]:38648 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab0DOEXM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 00:23:12 -0400
Received: by ywh32 with SMTP id 32so499919ywh.33
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 21:23:11 -0700 (PDT)
In-Reply-To: <1271304846.16881.1881.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 12:14 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 15 avril 2010 =C3=A0 05:40 +0200, Eric Dumazet a =C3=A9crit =
:
>
> Oh well, I revert this comment, we need a mutual exclusion between cp=
us
> if we dont want to miss some increments, even in a slow path.
>
> __get_cpu_var(netdev_rx_stat).field++; is safe because updated only b=
y
> this cpu.
>
> Once you use per_cpu(netdev_rx_stat, cpu).field++; you need a
> synchronization since this is not atomic.
>

rps_unlock() is a synchronization if needed.

> so queue->dropped++ is safer and faster too (inside the rps_lock
> section)
>

It involves more lines of code, moving netdev_rx_stat into softdata.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
