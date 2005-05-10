From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 12:43:30 -0700
Message-ID: <1115754210.8570.63.camel@rh4>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
 <1115743966.8570.26.camel@rh4>
 <20050510.121214.39158393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mperaya@alcazaba.unex.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050510.121214.39158393.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-10 at 12:12 -0700, David S.Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Subject: Re: tg3 support broken on PPC, a workaround
> Date: Tue, 10 May 2005 09:52:46 -0700
> 
> > In the new code, the DMA write bursts will disconnect at multiples of
> > cache lines instead of 1 cache line. And DMA read bursts will not
> > disconnect at cache line boundaries.
> 
> We really should be disconnecting at single cacheline boundaries
> on RISC systems.  The PCI controllers on RISC machines are
> going to disconnect the tg3 when it crosses a cache line
> boundary, so all these setting do is waste PCI bandwidth.
> 
> From the sparc64 PCI controller programmer's manual:
> 
> "When a DMA burst transfer attempts to go past a cache line (64B)
>  boundary, U2P generates a disconnect.  This should cause the
>  master device to attempt the transaction again beginning at the
>  address of the next untransferred data."
> 

This should be fine. If the bridge requires termination at every cache
line, the bridge (target) will initiate disconnect and data will
terminate.

There is clear benefit in doing longer bursts when the bridge can handle
it.

It was explained to me that on some risc systems such as ppc, and
assuming the bridge can handle long DMA bursts, it is still best to
disconnect at page or cache line boundaries. The reason is that if the
burst stops at any arbitrary address, the bridge has to refetch the
cache line and often the mapping information. Disconnecting at multiple
cache lines is to address this problem while still achieving longer DMA
bursts.
