From: Asias He <asias@redhat.com>
Subject: Re: [RFC 2/5] VSOCK: Introduce virtio-vsock-common.ko
Date: Sun, 30 Jun 2013 07:45:50 +0800
Message-ID: <20130629234550.GC11388@hj.localdomain>
References: <1372320004-20502-1-git-send-email-asias@redhat.com>
	<1372320004-20502-3-git-send-email-asias@redhat.com>
	<20130628.213225.150653146873611065.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: acking@vmware.com, kvm@vger.kernel.org, dtor@vmware.com,
	netdev@vger.kernel.org, grantr@vmware.com,
	virtualization@lists.linux-foundation.org, penberg@kernel.org,
	mst@redhat.com, sasha.levin@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130628.213225.150653146873611065.davem@davemloft.net>
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

Hi David,

On Fri, Jun 28, 2013 at 09:32:25PM -0700, David Miller wrote:
> From: Asias He <asias@redhat.com>
> Date: Thu, 27 Jun 2013 16:00:01 +0800
> 
> > +static void
> > +virtio_transport_recv_dgram(struct sock *sk,
> > +			    struct virtio_vsock_pkt *pkt)
>  ...
> > +	memcpy(skb->data, pkt, sizeof(*pkt));
> > +	memcpy(skb->data + sizeof(*pkt), pkt->buf, pkt->len);
> 
> Are you sure this is right?
> 
> Shouldn't you be using "sizeof(struct virtio_vsock_hdr)" instead of
> "sizeof(*pkt)".  'pkt' is "struct virtio_vsock_pkt" and has all kinds
> of meta-data you probably don't mean to include in the SKB.

Right, virtio_vsock_hdr is enough. Will fix this.

Thanks for looking at this. 

-- 
Asias
