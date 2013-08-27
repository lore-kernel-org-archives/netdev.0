From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: =?UTF-8?B?UmU6IElzIGZhbGxiYWNrIHZob3N0X25ldCB0byBxZW11IGZvciBsaXY=?=
 =?UTF-8?B?ZSBtaWdyYXRlIGF2YWlsYWJsZe+8nw==?=
Date: Tue, 27 Aug 2013 15:04:54 +0800
Message-ID: <521C4F96.8000103@huawei.com>
References: <521C1DCF.5090202@huawei.com> <20130827041935.GA7263@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <jasowang@redhat.com>, <kvm@vger.kernel.org>,
	<netdev@vger.kernel.org>, <qianhuibin@huawei.com>,
	<wangfuhai@huawei.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20130827041935.GA7263@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/8/27 12:19, Michael S. Tsirkin wrote:
> On Tue, Aug 27, 2013 at 11:32:31AM +0800, Qin Chuanyu wrote:
>> Hi all
>>
>> I am participating in a project which try to port vhost_net on Xen=E3=
=80=82
>>
>> By change the memory copy and notify mechanism =EF=BC=8Ccurrently
>> virtio-net with vhost_net could run on Xen with good
>> performance=E3=80=82TCP receive throughput of single vnic from 2.77G=
bps up
>> to 6Gps=E3=80=82In VM receive side=EF=BC=8CI instead grant_copy with=
 grant_map +
>> memcopy=EF=BC=8Cit efficiently reduce the cost of grant_table spin_l=
ock of
>> dom0=EF=BC=8CSo the hole server TCP performance from 5.33Gps up to 9=
=2E5Gps=E3=80=82
>>
>> Now I am consider the live migrate of vhost_net on Xen=EF=BC=8Cvhost=
_net
>> use vhost_log for live migrate on Kvm=EF=BC=8Cbut qemu on Xen havn't=
 manage
>> the hole memory of VM=EF=BC=8CSo I am trying to fallback datapath fr=
om
>> vhost_net to qemu when doing live migrate =EF=BC=8Cand fallback data=
path
>> from qemu to
>> vhost_net again after vm migrate to new server=E3=80=82
>>
>> My question is=EF=BC=9A
>> 	why didn't vhost_net do the same fallback operation for live
>> migrate on KVM=EF=BC=8Cbut use vhost_log to mark the dirty page=EF=BC=
=9F
>> 	Is there any mechanism fault for the idea of fallback datapath from
>> vhost_net to qemu for live migrate=EF=BC=9F
>>
>> any question about the detail of vhost_net on Xen is welcome=E3=80=82
>>
>> Thanks
>>
>
> It should work, in practice.
>
> However, one issue with this approach that I see is that you
> are running two instances of virtio-net on the host:
> qemu and vhost-net, doubling your security surface
> for guest to host attack.
>
> I don't exactly see why does it matter that qemu doesn't manage
> the whole memory of a VM - vhost only needs to log
> memory writes that it performs.
>
>
> .
>
Thanks for your reply.

In fact=EF=BC=8CI am not sure that whether vhost_log could work on Xen =
live=20
migrate or not. Yes=EF=BC=8Cvhost_sync_dirty_bitmap work well on Kvm=EF=
=BC=8Cbut=20
vhost_net havn't run on Xen before=EF=BC=8Calthough the method=20
vhost_dev_sync_region -> memory_region_set_dirty -> xen_modified_memory=
=20
call sequence exist.

Have you considered the scene that vhost_migration_log code running on=20
Xen=EF=BC=9F If yes=EF=BC=8Cit sames much easier then fallback datapath=
 from vhost_net=20
to qemu for live migrate.


