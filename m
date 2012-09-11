From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH] net, cgroup: Fix boot failure due to iteration of uninitialized
 list
Date: Tue, 11 Sep 2012 16:51:26 +0530
Message-ID: <504F1EB6.6040602@linux.vnet.ibm.com>
References: <20120719162532.23505.85946.stgit@srivatsabhat.in.ibm.com> <500CA599.6030907@cn.fujitsu.com> <20120723114057.GA16518@hmsreliant.think-freely.org> <504DB2EE.2030700@linux.vnet.ibm.com> <20120910131603.GA29742@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gao feng <gaofeng@cn.fujitsu.com>, eric.dumazet@gmail.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mark.d.rustad@intel.com,
	john.r.fastabend@intel.com, lizefan@huawei.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120910131603.GA29742@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/10/2012 06:46 PM, Neil Horman wrote:
> On Mon, Sep 10, 2012 at 02:59:18PM +0530, Srivatsa S. Bhat wrote:
>> On 07/23/2012 05:10 PM, Neil Horman wrote:
>>> On Mon, Jul 23, 2012 at 09:15:05AM +0800, Gao feng wrote:
>>>> =E4=BA=8E 2012=E5=B9=B407=E6=9C=8820=E6=97=A5 00:27, Srivatsa S. B=
hat =E5=86=99=E9=81=93:
>>>>> After commit ef209f15 (net: cgroup: fix access the unallocated me=
mory in
>>>>> netprio cgroup), boot fails with the following NULL pointer deref=
erence:
>>>>>
>> [...]
>>>>> Call Trace:
>>>>>  [<ffffffff81b1cb78>] cgroup_init_subsys+0x83/0x169
>>>>>  [<ffffffff81b1ce13>] cgroup_init+0x36/0x119
>>>>>  [<ffffffff81affef7>] start_kernel+0x3ba/0x3ef
>>>>>  [<ffffffff81aff95b>] ? kernel_init+0x27b/0x27b
>>>>>  [<ffffffff81aff356>] x86_64_start_reservations+0x131/0x136
>>>>>  [<ffffffff81aff45e>] x86_64_start_kernel+0x103/0x112
>>>>> RIP  [<ffffffff8145e8d6>] cgrp_create+0xf6/0x190
>>>>>  RSP <ffffffff81a01ea8>
>>>>> CR2: 0000000000000698
>>>>> ---[ end trace a7919e7f17c0a725 ]---
>>>>> Kernel panic - not syncing: Attempted to kill the idle task!
>>>>>
>>>>> The code corresponds to:
>>>>>
>>>>> update_netdev_tables():
>>>>>         for_each_netdev(&init_net, dev) {
>>>>>                 map =3D rtnl_dereference(dev->priomap);  <---- HE=
RE
>>>>>
>>>>>
>>>>> The list head is initialized in netdev_init(), which is called mu=
ch
>>>>> later than cgrp_create(). So the problem is that we are calling
>>>>> update_netdev_tables() way too early (in cgrp_create()), which wi=
ll
>>>>> end up traversing the not-yet-circular linked list. So at some po=
int,
>>>>> the dev pointer will become NULL and hence dev->priomap becomes a=
n
>>>>> invalid access.
>>>>>
>>>>> To fix this, just remove the update_netdev_tables() function enti=
rely,
>>>>> since it appears that write_update_netdev_table() will handle thi=
ngs
>>>>> just fine.
>>>>
>>>> The reason I add update_netdev_tables in cgrp_create is to avoid a=
dditional
>>>> bound checkings when we accessing the dev->priomap.priomap.
>>>>
>>>> Eric,can we revert this commit 91c68ce2b26319248a32d7baa1226f819d2=
83758 now?
>>>> I think it's safe enough to access priomap without bound check.
>>>>
>>>
>>> I think its probably safe, yes, but lets leave it there for just a =
bit.  Its not
>>> hurting anything, and I'd like to look into getting Srivatsa' patch=
 in first.
>>
>> Hi Neil,
>>
>> Did you get around to look into this again?
>>
> I haven't looked at it specifically no, I apologize.  That said I thi=
nk the
> other changes that went in back in that time frame have had time to s=
oak, and
> looking at the way we current update the priomap table, I think its s=
afe for us
> to remove the update_netdev_table call and definition.  If you repost=
 your
> patch, I'll ack it.=20
>=20

Cool! I'll repost the patch, along with another small improvement that =
I happened
to observe, as a separate patch. Thanks!

Regards,
Srivatsa S. Bhat
