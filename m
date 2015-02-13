From: Pawel Moll <pawel.moll@arm.com>
Subject: Re: [PATCH RFC v5 net-next 4/6] virtio-net: add basic interrupt
 coalescing support
Date: Fri, 13 Feb 2015 12:41:06 +0000
Message-ID: <1423831266.21394.1.camel@arm.com>
References: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
	 <1423471165-34243-5-git-send-email-jasowang@redhat.com>
	 <87386ey2iy.fsf@rustcorp.com.au> <20150210104019.GD9505@redhat.com>
	 <874mqqbk12.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"pagupta@redhat.com" <pagupta@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <874mqqbk12.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-02-13 at 02:52 +0000, Rusty Russell wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> > On Tue, Feb 10, 2015 at 12:02:37PM +1030, Rusty Russell wrote:
> >> Jason Wang <jasowang@redhat.com> writes:
> >> > This patch enables the interrupt coalescing setting through etht=
ool.
> >>=20
> >> The problem is that there's nothing network specific about interru=
pt
> >> coalescing.  I can see other devices wanting exactly the same thin=
g,
> >> which means we'd deprecate this in the next virtio standard.
> >>=20
> >> I think the right answer is to extend like we did with
> >> vring_used_event(), eg:
> >>=20
> >> 1) Add a new feature VIRTIO_F_RING_COALESCE.
> >> 2) Add another a 32-bit field after vring_used_event(), eg:
> >>         #define vring_used_delay(vr) (*(u32 *)((vr)->avail->ring[(=
vr)->num + 2]))
> >>=20
> >> This loses the ability to coalesce by number of frames, but we can=
 still
> >> do number of sg entries, as we do now with used_event, and we coul=
d
> >> change virtqueue_enable_cb_delayed() to take a precise number if w=
e
> >> wanted.
> >
> > But do we expect delay to be update dynamically?
> > If not, why not stick it in config space?
>=20
> Hmm, we could update it dynamically (and will, in the case of ethtool=
).
> But it won't be common, so we could append a field to
> virtio_pci_common_cfg for PCI.
>=20
> I think MMIO and CCW would be easy to extend too, but CC'd to check.

As far as I understand the virtio_pci_common_cfg principle (just had a
look, for the first time ;-), it's now an equivalent of the MMIO contro=
l
registers block. I see no major problem with adding another one.

Or were you thinking about introducing some standard for the "real"
config space? (fine with me as well - the transport will have nothing t=
o
do :-)

Pawe=C5=82
