From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] minor socket ioctl cleanup for 2.5.30
Date: Thu, 8 Aug 2002 21:13:15 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208081713.VAA02896@sex.inr.ac.ru>
References: <20020808170720.N24631@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Cc: davem@redhat.com, jmorris@intercode.com.au, netdev@oss.sgi.com,
   willy@debian.org
Return-path: <owner-netdev@oss.sgi.com>
To: willy@debian.org (Matthew Wilcox)
In-Reply-To: <20020808170720.N24631@parcelfarce.linux.theplanet.co.uk> from "Matthew Wilcox" at Aug 8, 2 05:07:20 pm
List-Id: netdev.vger.kernel.org

Hello!

> > Do we really want to do this?  What if some socket family either
> > doesn't want to support it or wants to handle it differently?
> 
> I rather think we do.  It's analagous to saying "What if some filesystem
> either doesn't want to support it or wants to handle it differently?"
> -- tough!  This is unix and filesystems (socket families) support this.

No, this is not true. This creepy ioctl is specific to TCP
(well, x.25 also uses SIGURG), which use kill*(sk->proc, SIGURG) directly.

Probably, it is better to move sk->proc to TCP private data,
this ioctl to tcp_ioctl(). Or... find a way to get rid of this completely,
not breaking compatibility with a few BSDish applications.

Alexey
