From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH v3] net: cgroup: fix access the unallocated memory in
 netprio cgroup
Date: Wed, 11 Jul 2012 20:51:42 +0800
Message-ID: <4FFD76DE.4090308@cn.fujitsu.com>
References: <1341995406-12719-1-git-send-email-gaofeng@cn.fujitsu.com> <20120711121102.GB26643@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, lizefan@huawei.com, tj@kernel.org,
	davem@davemloft.net, Eric Dumazet <edumazet@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120711121102.GB26643@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8811=E6=97=A5 20:11, Neil Horman =E5=86=
=99=E9=81=93:
> On Wed, Jul 11, 2012 at 04:30:06PM +0800, Gao feng wrote:
>> there are some out of bound accesses in netprio cgroup.
>>
>> now before accessing the dev->priomap.priomap array,we only check
>> if the dev->priomap exist.and because we don't want to see
>> additional bound checkings in fast path, so we should make sure
>> that dev->priomap is null or array size of dev->priomap.priomap
>> is equal to max_prioidx + 1;
>>
>> and it's not needed to call extend_netdev_tabel in write_priomap,
>> we can only allocate the net device's priomap which we change throug=
h
>> net_prio.ifpriomap.
>>
>> this patch add a return value for update_netdev_tables & extend_netd=
ev_table,
>> so when new_priomap is allocated failed,write_priomap will stop to a=
ccess
>> the priomap,and return -ENOMEM back to the userspace to tell the use=
r
>> what happend.
>>
>> Change From v2:
>> 1. protect extend_netdev_table by RTNL.
>> 2. when extend_netdev_table failed,call dev_put to reduce device's r=
efcount.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> ---
>>  net/core/netprio_cgroup.c |   54 ++++++++++++++++++++++++++++++++--=
----------
>>  1 files changed, 39 insertions(+), 15 deletions(-)
>>
> I still think the use of max_priomap in write_priomap is racy (please=
 see my
> previous note).
>=20
> Neil

Yes, you are right :(
we need a v4 patch.

Thanks!
