From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: =?UTF-8?Q?Re=3A_=5BXen-devel=5D_Is_fallback_vhost=5Fnet_to_qemu_for_live_migrate_available=EF=BC=9F?=
Date: Thu, 5 Sep 2013 14:33:55 +0100
Message-ID: <alpine.DEB.2.02.1309051429360.6397@kaball.uk.xensource.com>
References: <521C1DCF.5090202@huawei.com> <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com> <522174D7.6080903@huawei.com> <20130902075722.GZ15729@zion.uk.xensource.com> <52253B2B.6050909@huawei.com> <20130903084047.GF14104@zion.uk.xensource.com>
 <20130903085556.GD18901@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="1342847746-1901535139-1378388035=:6397"
Cc: Wei Liu <wei.liu2@citrix.com>, <qianhuibin@huawei.com>,
	KVM list <kvm@vger.kernel.org>, <likunyun@huawei.com>,
	<netdev@vger.kernel.org>, <jasowang@redhat.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	<liuyongan@huawei.com>, <liuyingdong@huawei.com>,
	<wangfuhai@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>,
	Qin Chuanyu <qinchuanyu@huawei.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20130903085556.GD18901@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--1342847746-1901535139-1378388035=:6397
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 3 Sep 2013, Michael S. Tsirkin wrote:
> On Tue, Sep 03, 2013 at 09:40:48AM +0100, Wei Liu wrote:
> > On Tue, Sep 03, 2013 at 09:28:11AM +0800, Qin Chuanyu wrote:
> > > On 2013/9/2 15:57, Wei Liu wrote:
> > > >On Sat, Aug 31, 2013 at 12:45:11PM +0800, Qin Chuanyu wrote:
> > > >>On 2013/8/30 0:08, Anthony Liguori wrote:
> > > >>>Hi Qin,
> > > >>
> > > >>>>By change the memory copy and notify mechanism =EF=BC=8Ccurrently=
 virtio-net with
> > > >>>>vhost_net could run on Xen with good performance=E3=80=82
> > > >>>
> > > >>>I think the key in doing this would be to implement a property
> > > >>>ioeventfd and irqfd interface in the driver domain kernel.  Just
> > > >>>hacking vhost_net with Xen specific knowledge would be pretty nast=
y
> > > >>>IMHO.
> > > >>>
> > > >>Yes, I add a kernel module which persist virtio-net pio_addr and
> > > >>msix address as what kvm module did. Guest wake up vhost thread by
> > > >>adding a hook func in evtchn_interrupt.
> > > >>
> > > >>>Did you modify the front end driver to do grant table mapping or i=
s
> > > >>>this all being done by mapping the domain's memory?
> > > >>>
> > > >>There is nothing changed in front end driver. Currently I use
> > > >>alloc_vm_area to get address space=EF=BC=8C and map the domain's me=
mory as
> > > >>what what qemu did.
> > > >>
> > > >
> > > >You mean you're using xc_map_foreign_range and friends in the backen=
d to
> > > >map guest memory? That's not very desirable as it violates Xen's
> > > >security model. It would not be too hard to pass grant references
> > > >instead of guest physical memory address IMHO.
> > > >
> > > In fact, I did what virtio-net have done in Qemu. I think security
> > > is a pseudo question because Dom0 is under control.

Right, but we are trying to move the backends out of Dom0, for
scalability and security.
Setting up a network driver domain is pretty easy and should work out of
the box with Xen 4.3.
That said, I agree that using xc_map_foreign_range is a good way to start.


> > Consider that you might have driver domains. Not every domain is under
> > control or trusted.
>=20
> I don't see anything that will prevent using driver domains here.

Driver domains are not privileged, therefore cannot map random guest
pages (unless they have been granted by the guest via the grant table).
xc_map_foreign_range can't work from a driver domain.


> > Also consider that security model like XSM can be
> > used to audit operations to enhance security so your foreign mapping
> > approach might not always work.
>=20
> It could be nice to have as an option, sure.
> XSM is disabled by default though so I don't think lack of support for
> that makes it a prototype.

There are some security aware Xen based products in the market today
that use XSM.
--1342847746-1901535139-1378388035=:6397--
