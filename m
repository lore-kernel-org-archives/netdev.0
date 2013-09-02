From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: Is fallback vhost_net to =?utf-8?Q?qem?=
 =?utf-8?Q?u_for_live_migrate_available=EF=BC=9F?=
Date: Mon, 2 Sep 2013 08:57:22 +0100
Message-ID: <20130902075722.GZ15729@zion.uk.xensource.com>
References: <521C1DCF.5090202@huawei.com>
 <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com>
 <522174D7.6080903@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	"Michael S. Tsirkin" <mst@redhat.com>, <jasowang@redhat.com>,
	KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	<qianhuibin@huawei.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	<wangfuhai@huawei.com>, <likunyun@huawei.com>,
	<liuyongan@huawei.com>, <liuyingdong@huawei.com>,
	<wei.liu2@citrix.com>
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:35229 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758156Ab3IBH5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 03:57:24 -0400
Content-Disposition: inline
In-Reply-To: <522174D7.6080903@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 31, 2013 at 12:45:11PM +0800, Qin Chuanyu wrote:
> On 2013/8/30 0:08, Anthony Liguori wrote:
> >Hi Qin,
>=20
> >>By change the memory copy and notify mechanism =EF=BC=8Ccurrently v=
irtio-net with
> >>vhost_net could run on Xen with good performance=E3=80=82
> >
> >I think the key in doing this would be to implement a property
> >ioeventfd and irqfd interface in the driver domain kernel.  Just
> >hacking vhost_net with Xen specific knowledge would be pretty nasty
> >IMHO.
> >
> Yes, I add a kernel module which persist virtio-net pio_addr and
> msix address as what kvm module did. Guest wake up vhost thread by
> adding a hook func in evtchn_interrupt.
>=20
> >Did you modify the front end driver to do grant table mapping or is
> >this all being done by mapping the domain's memory?
> >
> There is nothing changed in front end driver. Currently I use
> alloc_vm_area to get address space=EF=BC=8C and map the domain's memo=
ry as
> what what qemu did.
>=20

You mean you're using xc_map_foreign_range and friends in the backend t=
o
map guest memory? That's not very desirable as it violates Xen's
security model. It would not be too hard to pass grant references
instead of guest physical memory address IMHO.

Wei.
