From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH v2] net: cgroup: fix access the unallocated memory in
 netprio cgroup
Date: Wed, 11 Jul 2012 09:39:38 +0800
Message-ID: <4FFCD95A.1060204@cn.fujitsu.com>
References: <1341917043-13264-1-git-send-email-gaofeng@cn.fujitsu.com>  <1341918350.3265.4830.camel@edumazet-glaptop> <1341918530.3265.4839.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, lizefan@huawei.com, tj@kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341918530.3265.4839.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8810=E6=97=A5 19:08, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Tue, 2012-07-10 at 13:05 +0200, Eric Dumazet wrote:
>> On Tue, 2012-07-10 at 18:44 +0800, Gao feng wrote:
>>> there are some out of bound accesses in netprio cgroup.
>>
>>> -	update_netdev_tables();
>>> +	ret =3D extend_netdev_table(dev, max_len);
>>> +	if (ret < 0)
>>> +		goto out_free_devname;
>>> +
>>>  	ret =3D 0;
>>>  	rcu_read_lock();
>>>  	map =3D rcu_dereference(dev->priomap);
>>
>> Its unfortunately adding a bug.
>>
>> extend_netdev_table() is protected by RTNL.
>=20
> Please test your next patch using :
>=20
> CONFIG_LOCKDEP=3Dy
> CONFIG_PROVE_RCU=3Dy
>=20
> Because rtnl_dereference() should shout if you dont hold RTNL
>=20

Oops, I miss it.
Thanks Eric & Neil,I will test v3 patch with these two CONFIG.
