From: Jason Lunz <lunz@falooley.org>
Subject: Re: double-check me?
Date: Sun, 17 Aug 2003 21:34:22 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnbjvt6q.u4n.lunz@orr.homenet>
References: <3F3FBF50.8070207@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jgarzik@pobox.com said:
>          if (sizeof_priv)
>                  dev->priv = (void *) (((long)(dev + 1) + 31) & ~31);
> 
> 
> Now... shouldn't that last line of code be "dev + 1 + sizeof(*dev)" ?

are you missing that the "dev + 1" pointer arithmetic is already adding
sizeof(*dev) to dev, rather than just 1 byte? "(dev + 1)" is a pointer
to the private area after the actual struct net_device, and
"((long)(dev + 1) + 31)" adds 31 bytes of padding. The final "& ~31"
chops off any excess padding from the 31 that was added and actually
aligns the pointer.

Seems right to me, but I'm not used to playing alignment tricks.

Jason
