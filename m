From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 11:15:01 +0100
Message-ID: <1293790501.2973.33.camel@edumazet-laptop>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 10:29 +0100, stefani@seibold.n=
et a
=C3=A9crit :
> +				spin_lock_irqsave(&spinlock, flags);
> +				udpcp_stat.txMsgs++;
> +				spin_unlock_irqrestore(&spinlock, flags);

This is really ugly for different reasons :

1) Naming a lock, even static "spinlock" is ugly.
2) Using a lock for stats is not necessary, and
   disabling hard irqs is not necessary either (spinlock_bh() would be
more than enough)
 =20
   At a very minimum, you should use atomic_t so that no lock is needed

3) Network stack widely use MIB per_cpu counters.
 As you use UDP, you could take a look at UDP_INC_STATS_BH()/
UDP_INC_STATS_USER() implementation for an example.
