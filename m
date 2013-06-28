From: Andy King <acking@vmware.com>
Subject: Re: [RFC 0/5] Introduce VM Sockets virtio transport
Date: Thu, 27 Jun 2013 19:25:40 -0700 (PDT)
Message-ID: <1110962459.9928554.1372386340171.JavaMail.root@vmware.com>
References: <1372320004-20502-1-git-send-email-asias@redhat.com>
	<20130627102324.GA20215@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, Dmitry Torokhov <dtor@vmware.com>,
	netdev@vger.kernel.org, Reilly Grant <grantr@vmware.com>,
	virtualization@lists.linux-foundation.org,
	Pekka Enberg <penberg@kernel.org>, Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130627102324.GA20215@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Michael,

> >            __u32 guest_cid;
> 
> Given that cid is like an IP address, 32 bit seems too
> limiting. I would go for a 64 bit one or maybe even 128 bit,
> so that e.g. GUIDs can be used there.

That's likely based on what vSockets uses, which is in turn based on
what the VMCI device exposes (which is what vSockets was originally
built on), so unfortunately it's too late to extend that type.
However, that still allows just under 2^32 VMs per host (there are
three reserved values).

> >            __u32   dst_port;
> 
> Ports are 32 bit? I guess most applications can't work with >16 bit.

As with the cid, the width of the port type comes from vSockets,
which is what this plugs into.

> Also, why put cid's in all packets? They are only needed
> when you create a connection, no? Afterwards port numbers
> can be used.

The cid is present in DGRAM packets and STREAM _control_ packets
(connection handshake, signal read/write and so forth).  I don't
think the intent here is for it to be in STREAM _data_ packets,
but Asias can clarify.

> > Virtio VM socket connection creation:
> > 1) Client sends VIRTIO_VSOCK_OP_REQUEST to server
> > 2) Server reponses with VIRTIO_VSOCK_OP_NEGOTIATE to client
> > 3) Client sends VIRTIO_VSOCK_OP_OFFER to server
> > 4) Server responses with VIRTIO_VSOCK_OP_ATTACH to client
> 
> What's the reason for a 4 stage setup? Most transports
> make do with 3.

I'm guessing that's also based on the original vSockets/VMCI
implementation, where the NEGOTIATE/OFFER stages are used to
negotiate the underlying transport buffer size (in VMCI, the
queuepair that underlies a STREAM socket).  The virtio
transport can probably use 3.

Thanks!
- Andy
