From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Tue, 21 Dec 2010 16:24:35 +0100
Message-ID: <1292945075.2720.32.camel@edumazet-laptop>
References: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
	 <1292591363.2668.19.camel@mojatatu>
	 <AANLkTi=Eq1HuPwMMGQjk9x0QXp3_5djmAY6JeZyFkk0k@mail.gmail.com>
	 <1292936837.6535.8.camel@mojatatu>
	 <AANLkTimqemuhxCKq-PJu+FD-MDgKaHnYKnP_2ch30wxE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64101 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab0LUPYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 10:24:40 -0500
Received: by wyb28 with SMTP id 28so4052982wyb.19
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 07:24:39 -0800 (PST)
In-Reply-To: <AANLkTimqemuhxCKq-PJu+FD-MDgKaHnYKnP_2ch30wxE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 d=C3=A9cembre 2010 =C3=A0 22:03 +0800, Changli Gao a =C3=A9=
crit :
> However, I don't think change the rx queue mapping is a good idea.
> When the skbs returned from ifb enter netif_receive_skb() again,
> get_rps_cpu() may warn about the wrong rx queue, and my this patch is
> used to solve this problem. Even though the rx queue is legal, a
> different rps_cpus settings will be used, and the skbs may be
> redirected to different CPUs. Is it expected?
>=20
>=20

Do we really want a multi queue ifb at all ?

Why not use percpu data and LLTX, like we did for other virtual devices
(loopback, tunnels, vlans, ...)

I guess most ifb uses need to finaly deliver packets in a monoqueue
anyway, optimizing ifb might raise lock contention on this resource.

See what we did in commit 79640a4ca6955e3e (net: add additional lock to
qdisc to increase throughput) : Adding one spinlock actually helped a
lot ;)



