From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Is fallback vhost_net to =?utf-8?Q?qem?=
 =?utf-8?Q?u_for_live_migrate_available=EF=BC=9F?=
Date: Tue, 3 Sep 2013 11:55:56 +0300
Message-ID: <20130903085556.GD18901@redhat.com>
References: <521C1DCF.5090202@huawei.com>
 <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com>
 <522174D7.6080903@huawei.com>
 <20130902075722.GZ15729@zion.uk.xensource.com>
 <52253B2B.6050909@huawei.com>
 <20130903084047.GF14104@zion.uk.xensource.com>
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
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130903084047.GF14104@zion.uk.xensource.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 03, 2013 at 09:40:48AM +0100, Wei Liu wrote:
> On Tue, Sep 03, 2013 at 09:28:11AM +0800, Qin Chuanyu wrote:
> > On 2013/9/2 15:57, Wei Liu wrote:
> > >On Sat, Aug 31, 2013 at 12:45:11PM +0800, Qin Chuanyu wrote:
> > >>On 2013/8/30 0:08, Anthony Liguori wrote:
> > >>>Hi Qin,
> > >>
> > >>>>By change the memory copy and notify mechanism =EF=BC=8Ccurrent=
ly virtio-net with
> > >>>>vhost_net could run on Xen with good performance=E3=80=82
> > >>>
> > >>>I think the key in doing this would be to implement a property
> > >>>ioeventfd and irqfd interface in the driver domain kernel.  Just
> > >>>hacking vhost_net with Xen specific knowledge would be pretty na=
sty
> > >>>IMHO.
> > >>>
> > >>Yes, I add a kernel module which persist virtio-net pio_addr and
> > >>msix address as what kvm module did. Guest wake up vhost thread b=
y
> > >>adding a hook func in evtchn_interrupt.
> > >>
> > >>>Did you modify the front end driver to do grant table mapping or=
 is
> > >>>this all being done by mapping the domain's memory?
> > >>>
> > >>There is nothing changed in front end driver. Currently I use
> > >>alloc_vm_area to get address space=EF=BC=8C and map the domain's =
memory as
> > >>what what qemu did.
> > >>
> > >
> > >You mean you're using xc_map_foreign_range and friends in the back=
end to
> > >map guest memory? That's not very desirable as it violates Xen's
> > >security model. It would not be too hard to pass grant references
> > >instead of guest physical memory address IMHO.
> > >
> > In fact, I did what virtio-net have done in Qemu. I think security
> > is a pseudo question because Dom0 is under control.
> >=20
>=20
> Consider that you might have driver domains. Not every domain is unde=
r
> control or trusted.

I don't see anything that will prevent using driver domains here.

> Also consider that security model like XSM can be
> used to audit operations to enhance security so your foreign mapping
> approach might not always work.

It could be nice to have as an option, sure.
XSM is disabled by default though so I don't think lack of support for
that makes it a prototype.

> In short term foreign mapping can save you some time implementing the
> prototype.
> In long term using grant table is the proper way to go. And
> IMHO the benifit outweights the cost.
>=20
> Wei.

I'm guessing direct access could be quite a bit faster.
But someone would have to implement your idea in order to
do a cost/benefit analysis.

> > Host could access memory of guest in KVM much easier than Xen,
> > but I hadn't heard someone said KVM is un-secret.
> >=20
> > Regards
> > Qin chuanyu
> >=20
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
