From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Is fallback vhost_net to =?utf-8?Q?qem?=
 =?utf-8?Q?u_for_live_migrate_available=EF=BC=9F?=
Date: Tue, 27 Aug 2013 10:16:55 +0300
Message-ID: <20130827071655.GA17030@redhat.com>
References: <521C1DCF.5090202@huawei.com>
 <20130827041935.GA7263@redhat.com>
 <521C4F96.8000103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jasowang@redhat.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	qianhuibin@huawei.com, wangfuhai@huawei.com
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38719 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055Ab3H0HPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 03:15:08 -0400
Content-Disposition: inline
In-Reply-To: <521C4F96.8000103@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 03:04:54PM +0800, Qin Chuanyu wrote:
> On 2013/8/27 12:19, Michael S. Tsirkin wrote:
> >On Tue, Aug 27, 2013 at 11:32:31AM +0800, Qin Chuanyu wrote:
> >>Hi all
> >>
> >>I am participating in a project which try to port vhost_net on Xen=E3=
=80=82
> >>
> >>By change the memory copy and notify mechanism =EF=BC=8Ccurrently
> >>virtio-net with vhost_net could run on Xen with good
> >>performance=E3=80=82TCP receive throughput of single vnic from 2.77=
Gbps up
> >>to 6Gps=E3=80=82In VM receive side=EF=BC=8CI instead grant_copy wit=
h grant_map +
> >>memcopy=EF=BC=8Cit efficiently reduce the cost of grant_table spin_=
lock of
> >>dom0=EF=BC=8CSo the hole server TCP performance from 5.33Gps up to =
9.5Gps=E3=80=82
> >>
> >>Now I am consider the live migrate of vhost_net on Xen=EF=BC=8Cvhos=
t_net
> >>use vhost_log for live migrate on Kvm=EF=BC=8Cbut qemu on Xen havn'=
t manage
> >>the hole memory of VM=EF=BC=8CSo I am trying to fallback datapath f=
rom
> >>vhost_net to qemu when doing live migrate =EF=BC=8Cand fallback dat=
apath
> >>from qemu to
> >>vhost_net again after vm migrate to new server=E3=80=82
> >>
> >>My question is=EF=BC=9A
> >>	why didn't vhost_net do the same fallback operation for live
> >>migrate on KVM=EF=BC=8Cbut use vhost_log to mark the dirty page=EF=BC=
=9F
> >>	Is there any mechanism fault for the idea of fallback datapath fro=
m
> >>vhost_net to qemu for live migrate=EF=BC=9F
> >>
> >>any question about the detail of vhost_net on Xen is welcome=E3=80=82
> >>
> >>Thanks
> >>
> >
> >It should work, in practice.
> >
> >However, one issue with this approach that I see is that you
> >are running two instances of virtio-net on the host:
> >qemu and vhost-net, doubling your security surface
> >for guest to host attack.
> >
> >I don't exactly see why does it matter that qemu doesn't manage
> >the whole memory of a VM - vhost only needs to log
> >memory writes that it performs.
> >
> >
> >.
> >
> Thanks for your reply.
>=20
> In fact=EF=BC=8CI am not sure that whether vhost_log could work on Xe=
n live
> migrate or not. Yes=EF=BC=8Cvhost_sync_dirty_bitmap work well on Kvm=EF=
=BC=8Cbut
> vhost_net havn't run on Xen before=EF=BC=8Calthough the method
> vhost_dev_sync_region -> memory_region_set_dirty ->
> xen_modified_memory call sequence exist.
>=20
> Have you considered the scene that vhost_migration_log code running
> on Xen=EF=BC=9F If yes=EF=BC=8Cit sames much easier then fallback dat=
apath from
> vhost_net to qemu for live migrate.
>=20

I never looked at how Xen live migration works with QEMU so I don't
know.
