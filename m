From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.34-rc1: rcu lockdep bug?
Date: Fri, 12 Mar 2010 16:59:33 +0800
Message-ID: <2375c9f91003120059g771d162fxefc21beb2ab17b4d@mail.gmail.com>
References: <20100311134556.GA6344@linux.vnet.ibm.com>
	 <20100311161751.GA3804@hack>
	 <2375c9f91003112356g1b4164e4pb5f63f0e0e2f310a@mail.gmail.com>
	 <20100312.000705.225033546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100312.000705.225033546.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 12, 2010 at 4:07 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>
> Date: Fri, 12 Mar 2010 15:56:03 +0800
>
>> Ok, after decoding the lockdep output, it looks like that
>> netif_receive_skb() should call rcu_read_lock_bh() instead of rcu_re=
ad_lock()?
>> But I don't know if all callers of netif_receive_skb() are in softir=
q context.
>
> Normally, netif_receive_skb() is invoked from softirq context.
>
> However, via netpoll it can be invoked essentially from any context.
>
> But, when this happens, the networking receive path makes amends such
> that this works fine. =C2=A0That's what the netpoll_receive_skb() che=
ck in
> netif_receive_skb() is for. =C2=A0That check makes it bail out early =
if the
> call to netif_receive_skb() is via a netpoll invocation.
>

Oh, I see. This means we should call rcu_read_lock_bh() instead.
If Paul has no objections, I will send a patch for this.

Thanks much, David!
