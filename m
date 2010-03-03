From: David Miller <davem@davemloft.net>
Subject: Re: [rfc/rft][patch] should use scheduler sync hint in
 tcp_prequeue()?
Date: Wed, 03 Mar 2010 06:05:29 -0800 (PST)
Message-ID: <20100303.060529.195713861.davem@davemloft.net>
References: <1267522901.25906.101.camel@marge.simson.net>
	<1267529273.2964.111.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: efault@gmx.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267529273.2964.111.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 02 Mar 2010 12:27:53 +0100

> Le mardi 02 mars 2010 =E0 10:41 +0100, Mike Galbraith a =E9crit :
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index 34f5cc2..ba3fc64 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -939,7 +939,7 @@ static inline int tcp_prequeue(struct sock *sk, =
struct sk_buff *skb)
>> =20
>>  		tp->ucopy.memory =3D 0;
>>  	} else if (skb_queue_len(&tp->ucopy.prequeue) =3D=3D 1) {
>> -		wake_up_interruptible_poll(sk->sk_sleep,
>> +		wake_up_interruptible_sync_poll(sk->sk_sleep,
>>  					   POLLIN | POLLRDNORM | POLLRDBAND);
>>  		if (!inet_csk_ack_scheduled(sk))
>>  			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
>>=20
 ...
> Ingo probably can answer to this question, since he changed
> sock_def_readable() (and others) in commit 6f3d09291b498299
> I suspect he missed tcp_prequeue() case, maybe not...

It definitely looks like an oversight to me and we should add
be using wake_up_interruptible_sync_poll() in tcp_prequeue()
as above.

Ingo?
