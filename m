From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] minor socket ioctl cleanup for 2.5.30
Date: Thu, 8 Aug 2002 18:17:17 +0100
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020808181717.P24631@parcelfarce.linux.theplanet.co.uk>
References: <20020808170720.N24631@parcelfarce.linux.theplanet.co.uk> <200208081713.VAA02896@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, davem@redhat.com,
   jmorris@intercode.com.au, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208081713.VAA02896@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Thu, Aug 08, 2002 at 09:13:15PM +0400
List-Id: netdev.vger.kernel.org

On Thu, Aug 08, 2002 at 09:13:15PM +0400, kuznet@ms2.inr.ac.ru wrote:
> No, this is not true. This creepy ioctl is specific to TCP
> (well, x.25 also uses SIGURG), which use kill*(sk->proc, SIGURG) directly.
> 
> Probably, it is better to move sk->proc to TCP private data,
> this ioctl to tcp_ioctl(). Or... find a way to get rid of this completely,
> not breaking compatibility with a few BSDish applications.

jamesm also has patches which remove sk->proc altogether and make TCP
use the normal fasync methods.  this ioctl then does an f_setown and
most of the creepiness is gone.  consider this patch a stepping-stone.

-- 
Revolutions do not require corporate support.
