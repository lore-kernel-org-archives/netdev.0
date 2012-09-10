From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: (ipt_log_packet, sb_add) 3.6.0-rc2 kernel panic - not syncing;
 Fatal exception in interrupt
Date: Mon, 10 Sep 2012 07:02:04 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209100659220.22738@frira.zrqbmnf.qr>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>  <20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>  <20120902132834.GB7456@breakpoint.cc> <1346626385.2563.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Florian Westphal <fw@strlen.de>,
	Sami Farin <hvtaifwkbgefbaei@gmail.com>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:54390 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751233Ab2IJFCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 01:02:07 -0400
In-Reply-To: <1346626385.2563.44.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2012-09-03 00:53, Eric Dumazet wrote:
>[PATCH] xt_LOG: take care of timewait sockets
>
>Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
>full blown socket.
>
>But with TCP early demux, we can have skb->sk pointing to a timewait
>socket.
>
>+static void dump_sk_uid_gid(struct sbuff *m, struct sock *sk)
>+{
>+	if (!sk || sk->sk_state == TCP_TIME_WAIT)
>+		return;
>+
>+	read_lock_bh(&sk->sk_callback_lock);
>+	if (sk->sk_socket && sk->sk_socket->file)
>+		sb_add(m, "UID=%u GID=%u ",
>+			sk->sk_socket->file->f_cred->fsuid,
>+			sk->sk_socket->file->f_cred->fsgid);

xt_owner.c is also using f_cred, so it might need the same,
does it not?
