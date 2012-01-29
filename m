From: Ryan Hajdaj <rhajdaj@gmail.com>
Subject: Re: [PATCH 001/001] net: Add tx_queue/rx_queue info to /proc/net/unix
Date: Sun, 29 Jan 2012 15:56:41 -0500
Message-ID: <CAB0C5qLhUL6fKcZsjmfs1At8wWk7vQhpXOdk0S85fxypiW28Og@mail.gmail.com>
References: <CAB0C5qK1FGc5xhGxGzpmELbWfC6GVVxEB9Zan_nU9cC_MxMzew@mail.gmail.com>
	<1327805865.2805.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327805865.2805.23.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acknowledged, unix_diag (ss command) addresses the need for this patch.
- Ryan

On 1/28/12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le samedi 28 janvier 2012 =E0 21:37 -0500, Ryan Hajdaj a =E9crit :
>> From: Ryan Hajdaj <rhajdaj@gmail.com>
>>
>> Add tx_queue/rx_queue info to /proc/net/unix (unix_seq_show)
>>
>> Signed-off-by: Ryan Hajdaj <rhajdaj@gmail.com>
>> Tested-by: Ryan Hajdaj <rhajdaj@gmail.com>
>> ---
>> tx_queue/rx_queue info is useful in systems with multiple processes
>> using Unix Domain sockets to communicate, as it can be used to check
>> process health "at a glance".
>> Unit tested on Unix stream and datagram sockets.
>> --- linux-3.3-rc1/net/unix/af_unix.c.orig	2012-01-28 20:36:33.000000=
000
>> +0000
>> +++ linux-3.3-rc1/net/unix/af_unix.c	2012-01-28 19:09:18.000000000 +=
0000
>> @@ -2286,13 +2286,14 @@ static int unix_seq_show(struct seq_file
>>
>>  	if (v =3D=3D SEQ_START_TOKEN)
>>  		seq_puts(seq, "Num       RefCount Protocol Flags    Type St "
>> -			 "Inode Path\n");
>> +			 "tx_queue rx_queue Inode Path\n");
>>  	else {
>>  		struct sock *s =3D v;
>>  		struct unix_sock *u =3D unix_sk(s);
>>  		unix_state_lock(s);
>>
>> -		seq_printf(seq, "%pK: %08X %08X %08X %04X %02X %5lu",
>> +		seq_printf(seq,
>> +			"%pK: %08X %08X %08X %04X %02X %08lX %08lX %5lu",
>>  			s,
>>  			atomic_read(&s->sk_refcnt),
>>  			0,
>> @@ -2301,6 +2302,8 @@ static int unix_seq_show(struct seq_file
>>  			s->sk_socket ?
>>  			(s->sk_state =3D=3D TCP_ESTABLISHED ? SS_CONNECTED : SS_UNCONNEC=
TED) :
>>  			(s->sk_state =3D=3D TCP_ESTABLISHED ? SS_CONNECTING : SS_DISCONN=
ECTING),
>> +			unix_outq_len(s),
>> +			(unix_inq_len(s) < 0 ? 0 : unix_inq_len(s)),
>>  			sock_i_ino(s));
>>
>>  		if (u->addr) {
>
> You missed some discussion on netdev about this kind of patches.
>
> /proc/net/unix format is frozen.
>
> Pavel Emelyanov did the work to support unix_diag, where you can find
> all you need.
>
>
>
>
