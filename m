From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
Date: Wed, 12 Aug 2009 10:16:36 +0300
Message-ID: <20090812071636.GA26847@redhat.com>
References: <20090811212743.GA26309@redhat.com> <4A820391.1090404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu,
        linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <4A820391.1090404@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 11, 2009 at 07:49:37PM -0400, Gregory Haskins wrote:
> Michael S. Tsirkin wrote:
> > This implements vhost: a kernel-level backend for virtio,
> > The main motivation for this work is to reduce virtualization
> > overhead for virtio by removing system calls on data path,
> > without guest changes. For virtio-net, this removes up to
> > 4 system calls per packet: vm exit for kick, reentry for kick,
> > iothread wakeup for packet, interrupt injection for packet.
> > 
> > Some more detailed description attached to the patch itself.
> > 
> > The patches are against 2.6.31-rc4.  I'd like them to go into linux-next
> > and down the road 2.6.32 if possible.  Please comment.
> 
> I will add this series to my benchmark run in the next day or so.  Any
> specific instructions on how to set it up and run?
> 
> Regards,
> -Greg
> 

1. use a dedicated network interface with SRIOV, program mac to match
   that of guest (for testing, you can set promisc mode, but that is
   bad for performance)
2. disable tso,gso,lro with ethtool
3. add vhost=ethX

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
