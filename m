From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: cgroup: fix access the unallocated memory in netprio
 cgroup
Date: Tue, 10 Jul 2012 17:36:50 +0800
Message-ID: <4FFBF7B2.9070609@cn.fujitsu.com>
References: <1341837625.3265.2748.camel@edumazet-glaptop>  <1341887508-20302-1-git-send-email-gaofeng@cn.fujitsu.com>  <1341893650.3265.3974.camel@edumazet-glaptop>  <4FFBED84.1030905@cn.fujitsu.com> <1341911707.3265.4603.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizefan@huawei.com, tj@kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341911707.3265.4603.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8810=E6=97=A5 17:15, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Tue, 2012-07-10 at 16:53 +0800, Gao feng wrote:
>>> Hi Gao
>>>
>>> Is it still needed to call update_netdev_tables() from write_prioma=
p() ?
>>>
>>
>> Yes, I think it's needed,because read_priomap will show all of the n=
et devices,
>>
>> But we may add the netdev after create a netprio cgroup, so the new =
added netdev's
>> priomap will not be allocated. if we don't call update_netdev_tables=
 in write_priomap,
>> we may access this unallocated memory.
>>
>=20
> I realize my question was not clear.
>=20
> If we write in write_priomap() a field of a single netdevice,
> why should we allocate memory for all netdevices on the machine ?
>=20
> So the question was : Do we really need to call
> update_netdev_tables(alldevs), instead of extend_netdev_table(dev)
>=20
>=20

I get it.

You are right,Indeed we only need to call extend_netdev_table
for the netdev witch we want to change.

and I read the commit f5c38208d32412d72b97a4f0d44af0eb39feb20b,
found why we need delay allocation.

I will send a v2 patch.

Thanks!
