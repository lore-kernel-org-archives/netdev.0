From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Is fallback vhost_net to =?utf-8?Q?qem?=
 =?utf-8?Q?u_for_live_migrate_available=EF=BC=9F?=
Date: Mon, 2 Sep 2013 11:11:47 +0300
Message-ID: <20130902081147.GA21387@redhat.com>
References: <521C1DCF.5090202@huawei.com>
 <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com>
 <522174D7.6080903@huawei.com>
 <20130902075722.GZ15729@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Qin Chuanyu <qinchuanyu@huawei.com>,
	Anthony Liguori <anthony@codemonkey.ws>, jasowang@redhat.com,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org,
	qianhuibin@huawei.com,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	wangfuhai@huawei.com, likunyun@huawei.com, liuyongan@huawei.com,
	liuyingdong@huawei.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789Ab3IBILH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 04:11:07 -0400
Content-Disposition: inline
In-Reply-To: <20130902075722.GZ15729@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 02, 2013 at 08:57:22AM +0100, Wei Liu wrote:
> On Sat, Aug 31, 2013 at 12:45:11PM +0800, Qin Chuanyu wrote:
> > On 2013/8/30 0:08, Anthony Liguori wrote:
> > >Hi Qin,
> >=20
> > >>By change the memory copy and notify mechanism =EF=BC=8Ccurrently=
 virtio-net with
> > >>vhost_net could run on Xen with good performance=E3=80=82
> > >
> > >I think the key in doing this would be to implement a property
> > >ioeventfd and irqfd interface in the driver domain kernel.  Just
> > >hacking vhost_net with Xen specific knowledge would be pretty nast=
y
> > >IMHO.
> > >
> > Yes, I add a kernel module which persist virtio-net pio_addr and
> > msix address as what kvm module did. Guest wake up vhost thread by
> > adding a hook func in evtchn_interrupt.
> >=20
> > >Did you modify the front end driver to do grant table mapping or i=
s
> > >this all being done by mapping the domain's memory?
> > >
> > There is nothing changed in front end driver. Currently I use
> > alloc_vm_area to get address space=EF=BC=8C and map the domain's me=
mory as
> > what what qemu did.
> >=20
>=20
> You mean you're using xc_map_foreign_range and friends in the backend=
 to
> map guest memory? That's not very desirable as it violates Xen's
> security model. It would not be too hard to pass grant references
> instead of guest physical memory address IMHO.
>=20
> Wei.

It's a start and it should make it fast and work with existing
infrastructure in the host, though.

--=20
MST
