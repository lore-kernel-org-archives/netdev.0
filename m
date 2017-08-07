From: Adam Tao <taozhe1@huawei.com>
Subject: Re: repost: af_packet vs virtio (was packed ring layout
 proposal v2)
Date: Mon, 7 Aug 2017 12:16:23 +0800
Message-ID: <20170807041623.GA12132@shay3t003839711.china.huawei.com>
References: <20170414051304-mutt-send-email-mst@kernel.org>
 <20170414054318-mutt-send-email-mst@kernel.org>
 <CAJR92jnV1VgBs567QNjO1fHKDgMX=1j1aJJ2gK-TqMB5E1=fvw@mail.gmail.com>
 <20170802164931-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Steven Luong <sluong99@gmail.com>, <john.fastabend@gmail.com>,
        <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>,
        <virtio-dev@lists.oasis-open.org>,
        <virtualization@lists.linux-foundation.org>, <kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>,
        <g@shay3t003839711.china.huawei.com>
Return-path: <virtio-dev-return-2456-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
Content-Disposition: inline
In-Reply-To: <20170802164931-mutt-send-email-mst@kernel.org>
List-Id: netdev.vger.kernel.org

On Wed, Aug 02, 2017 at 04:50:03PM +0300, Michael S. Tsirkin wrote:
> On Tue, Aug 01, 2017 at 08:54:27PM -0700, Steven Luong wrote:
> >     * Descriptor ring:
> > 
> >     Guest adds descriptors with unique index values and DESC_HW set in flags.
> >     Host overwrites used descriptors with correct len, index, and DESC_HW
> >     clear.? Flags are always set/cleared last.
> > 
> >     #define DESC_HW 0x0080
> > 
> >     struct desc {
> >     ? ? ? ? __le64 addr;
> >     ? ? ? ? __le32 len;
> >     ? ? ? ? __le16 index;
> >     ? ? ? ? __le16 flags;
> >     };
> > 
> >     When DESC_HW is set, descriptor belongs to device. When it is clear,
> >     it belongs to the driver.
> > 
> >     We can use 1 bit to set direction
> >     /* This marks a buffer as write-only (otherwise read-only). */
> >     #define VRING_DESC_F_WRITE? ? ? 2
> > 
> >     * Scatter/gather support
> > 
> >     We can use 1 bit to chain s/g entries in a request, same as virtio 1.0:
> > 
> >     /* This marks a buffer as continuing via the next field. */
next field seems like a structure field in the software, maybe we need
to change the "next field" to "next desc" to avoid misunderstanding.
> > 
> > 
> > This comment here is confusing to me. In 1.0, virtq_desc has the next field.
> > When the flag VRING_DESC_F_NEXT is set, the next entry to continue is specified
> > in the next field.
> > 
> > Here in 1.1, struct desc does not have the next field, only addr, len, index,
> > and flags. So when VRING_DESC_F_NEXT is set in struct desc's flags field, where
> > is the next entry to continue the current descriptor, the entry immediately
> > following the current entry? ie, if the current entry is at index 10 in the
> > descriptor table and its flags is set for VRING_DESC_F_NEXT, is the entry
> > continuing the current entry in index 11?
> > 
> > Steven
> 
> Exactly, you got it right.
> 
> ---------------------------------------------------------------------
> To unsubscribe, e-mail: virtio-dev-unsubscribe@lists.oasis-open.org
> For additional commands, e-mail: virtio-dev-help@lists.oasis-open.org
