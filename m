From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] net: export TCP send buffer size via netlink
Date: Mon, 01 Feb 2010 17:04:33 +0800
Message-ID: <4B669921.6090808@redhat.com>
References: <20100201080256.4084.30962.sendpatchset@localhost.localdomain> <1265014309.2848.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265014309.2848.7.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le lundi 01 f=C3=A9vrier 2010 =C3=A0 02:59 -0500, Amerigo Wang a =C3=A9=
crit :
>> Currently, we can only get TCP send buffer size by
>> getsockopt (SO_SNDBUF or TCP_INFO), this is not enough
>> for the tools like netstat or ss to read.
>>
>> Show TCP send buffer size via netlink NETLINK_INET_DIAG.
>>
>> Signed-off-by: WANG Cong <amwang@redhat.com>
>> Cc: David Miller <davem@davemloft.net>
>>
>> ---
>> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>> index 7fee8a4..46768de 100644
>> --- a/include/linux/tcp.h
>> +++ b/include/linux/tcp.h
>> @@ -136,6 +136,7 @@ struct tcp_info {
>>  	__u32	tcpi_ato;
>>  	__u32	tcpi_snd_mss;
>>  	__u32	tcpi_rcv_mss;
>> +	__u32	tcpi_sndbuf;
>> =20
>>  	__u32	tcpi_unacked;
>>  	__u32	tcpi_sacked;
>=20
> You cannot change tcp_info like this, this structure is used by some
> programs, and they are going to break badly.
>=20

Oh, right, I forgot the ABI compatibility...
I will append it to this structure.

Thanks!
