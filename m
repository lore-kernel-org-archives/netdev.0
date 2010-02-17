From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v4 3/3] net: reserve ports for applications using
 fixed port numbers
Date: Thu, 18 Feb 2010 00:13:14 +0800
Message-ID: <4B7C159A.3060603@redhat.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com>	 <1266271241-6293-4-git-send-email-opurdila@ixiacom.com>	 <4B7A6740.1000701@redhat.com> <201002161306.29708.opurdila@ixiacom.com>	 <4B7A9852.5020105@redhat.com> <1266326425.3045.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266326425.3045.53.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le mardi 16 f=C3=A9vrier 2010 =C3=A0 21:06 +0800, Cong Wang a =C3=A9c=
rit :
>> Octavian Purdila wrote:
>>> On Tuesday 16 February 2010 11:37:04 you wrote:
>>>>>  	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > sizeof(dummy_skb->c=
b));
>>>>>
>>>>> +	sysctl_local_reserved_ports =3D kzalloc(65536 / 8, GFP_KERNEL);
>>>>> +	if (!sysctl_local_reserved_ports)
>>>>> +		goto out;
>>>>> +
>>>> I think we should also consider the ports in ip_local_port_range,
>>>> since we can only reserve the ports in that range.
>>>>
>>> That is subject to changes at runtime, which means we will have to =
readjust=20
>>> the bitmap at runtime which introduces the need for additional sync=
hronization=20
>>> operations which I would rather avoid.=20
>> Why? As long as the bitmap is global, this will not be hard.
>>
>> Consider that if one user writes a port number which is beyond
>> the ip_local_port_range into ip_local_reserved_ports, we should
>> not accept this, because it doesn't make any sense. But with your
>> patch, we do.
>=20
> I disagree with you. This is perfectly OK.
>=20
> A port not being flagged in ip_local_reserved_ports doesnt mean it ca=
n
> be used for allocation.
>=20
> If you want to really block ports from being used at boot, you could =
for
> example :
>=20
> # temporarly reduce the ip_local_port_range
> echo "61000 61001" >/proc/sys/net/ipv4/ip_local_port_range
> # Build our bitmap (could be slow, if a remote database is read)
> for port in $LIST_RESERVED_PORT
> do
>   echo $port >/proc/sys/net/ipv4/ip_local_reserved_ports
> done
> echo "10000 61000" >/proc/sys/net/ipv4/ip_local_port_range
>=20
>=20

I don't think so, if you want to avoid race condition, you just need to
write the reserved ports before any networking application starts, IOW,
as early as possible during boot.

Thanks.
