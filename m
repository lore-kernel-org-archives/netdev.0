From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: double-check me?
Date: 17 Aug 2003 22:58:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3n0e8uhl4.fsf@defiant.pm.waw.pl>
References: <3F3FBF50.8070207@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maillist netdev <netdev@oss.sgi.com>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F3FBF50.8070207@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> writes:

> Maybe you guys can spot something I'm missing here.  alloc_netdev is
> supposed to guarantee that dev->priv is aligned by 32 bytes:
> 
>          struct net_device *dev;
> 
>          if (sizeof_priv)
>                  dev->priv = (void *) (((long)(dev + 1) + 31) & ~31);
> 
> 
> Now... shouldn't that last line of code be "dev + 1 + sizeof(*dev)" ?
> 
> It seems to work 2.[456] for a long time, so I am doubting
> myself... surely it would have caused memory corruption or something
> by now if I have really found a bug.

Looks ok... not very readable, though.

dev + 1 = ((u8*)dev) + sizeof(dev) = pointer to end of net_device struct.

(X + 31) & ~31 makes sure X is 32-bytes aligned (0-31 bytes are added).
Hope the alloc_size has enough space for this.

31 should be better 0x1F I think.

I also like sizeof(struct net_device) more than sizeof(*dev).

Why do you want "+ 1" if you add sizeof(*dev)?
-- 
Krzysztof Halasa
Network Administrator
