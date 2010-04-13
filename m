From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sk_dst_cache RCUification
Date: Wed, 14 Apr 2010 01:04:05 +0200
Message-ID: <1271199845.16881.586.camel@edumazet-laptop>
References: <1270803809.2623.69.camel@edumazet-laptop>
	 <20100413.015232.67916764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44600 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901Ab0DMXEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 19:04:11 -0400
Received: by bwz19 with SMTP id 19so84611bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 16:04:09 -0700 (PDT)
In-Reply-To: <20100413.015232.67916764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 01:52 -0700, David Miller a =C3=A9crit :

> Applied, thanks for doing this work Eric.

Thanks David :)

I am now working on sk_callback_lock case, to speedup
sock_def_readable(), sock_def_write_space() in typical cases
(SOCK_FASYNC not set)

Instead of using rcu on whole "struct socket", my plan is to use a smal=
l
structure :

struct wait_queue_head_rcu {
	wait_queue_head_t wait;
	struct rcu_head	  rcu;
} ____cacheline_aligned_in_smp;

and make sk->sk_sleep points to this 'wait' field.


