From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port
 numbers
Date: Wed, 03 Feb 2010 13:15:45 +0800
Message-ID: <4B690681.6070908@redhat.com>
References: <20100203043332.3817.27932.sendpatchset@localhost.localdomain> <1265171993.3274.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1265171993.3274.3.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le mardi 02 f=C3=A9vrier 2010 =C3=A0 23:30 -0500, Amerigo Wang a =C3=A9=
crit :
>> This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports,
>> it can be used like ip_local_port_range, but this is used to
>> reserve ports for third-party applications which use fixed
>> port numbers within ip_local_port_range.
>>
>> This only affects the applications which call socket functions
>> like bind(2) with port number 0, to prevent the kernel getting the p=
orts
>> within the specified range for them. For applications which use fixe=
d
>> port number, it will have no effects.
>>
>> Any comments are welcome.
>>
>> Signed-off-by: WANG Cong <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
>> Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>=20
>>  		.procname	=3D "igmp_max_memberships",
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index f0126fd..83045ca 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -210,8 +210,11 @@ int udp_lib_get_port(struct sock *sk, unsigned =
short snum,
>>  		inet_get_local_port_range(&low, &high);
>>  		remaining =3D (high - low) + 1;
>> =20
>> +again:
>>  		rand =3D net_random();
>>  		first =3D (((u64)rand * remaining) >> 32) + low;
>> +		if (inet_is_reserved_local_port(first))
>> +			goto again;
>>  		/*
>>  		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
>>  		 */
>=20
> Unless I misread the patch, you are checking only the 'first' port th=
at
> udp_lib_get_port() chose.
>=20
> I would use inet_get_local_reserved_ports(&min_res, &max_res);
> and check every port that we chose in the loop to avoid it if necessa=
ry.
>=20

Hmm, right, 'first' is used to do iteration, but I did missed 'last'.
Thanks! I will fix this in the next update.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
