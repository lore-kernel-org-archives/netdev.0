From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Re: dev_add_pack and hardware checksumming
Date: Mon, 18 Aug 2003 20:27:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818182727.GD999@vana.vc.cvut.cz>
References: <20030818033711.GA21360@vana.vc.cvut.cz> <20030817223851.5185bdee.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030817223851.5185bdee.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 17, 2003 at 10:38:51PM -0700, David S. Miller wrote:
> On Mon, 18 Aug 2003 05:37:11 +0200
> Petr Vandrovec <vandrove@vc.cvut.cz> wrote:
> 
> >   For me it would be best if dev_queue_xmit_nit could just leave
> > skb->h.raw alone,
> 
> The AF_PACKET layer depends upon skb->h.raw being set a certain
> way.  Have a look at the dev_add_pack() registered hooks that
> net/packet/af_packet.c uses.

Well, I do not see skb->h.raw used in any way in AF_PACKET hooks...
Probably I missed some deeply nested generic function which accesses
it...
 
> > Other choice is doing checksumming in dev_queue_xmit_nit itself,
> > before passing skb down to the registered packet handlers.
> 
> This is not an option either.  We're specifically not going to
> undo checksum offloading just because tcpdump or some other
> kind of tap is installed.

And what's left, then? I can happilly offload checksum to some
other place down in the chain, but for doing that I must know
where I should put checksum, and currently this information is
unavailable to the packet hook.
				Best regards,
					Petr Vandrovec
 
