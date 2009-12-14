From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: packet_sendmsg_spkt sleeping from invalid context
Date: Mon, 14 Dec 2009 22:25:57 +0100
Message-ID: <4B26AD65.1020004@gmail.com>
References: <20091214175211.GA5102@nowhere> <4B2690E7.4030303@gmail.com> <20091214205231.GB5037@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933080AbZLNV0S@vger.kernel.org>
In-Reply-To: <20091214205231.GB5037@nowhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14/12/2009 21:52, Frederic Weisbecker a =E9crit :
>=20
> I also wonder. Are you using PREEMPT_RCU ?

Not at all :)

But yes, this is illegal to do the memcpy_fromiovec() in rcu_read_lock(=
) context.

> That may explain why you haven't seen this issue because
> might_sleep() doesn't see you are in a rcu read locked
> section as preemption is not disabled, but it is illegal to
> voluntarily sleep in such area (although it's fine with
> preempt rcu) as doing so with non-prempt RCU config would barf.
>=20
> I'm trying a patch to handle that.

As you want, I also have a patch testing right now :)
