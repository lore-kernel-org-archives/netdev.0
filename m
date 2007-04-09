From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Mon, 9 Apr 2007 11:46:31 -0400
Message-ID: <200704091146.32346.rgetz@blackfin.uclinux.org>
References: <6d6a94c50704082001y5c13c865ic3d70217aba7d181@mail.gmail.com> <1176112223.17975.8.camel@roc-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Alan Cox" <alan@lxorguk.ukuu.org.uk>, waltje@uwalt.nl.mugnet.org,
	"Aubrey Li" <aubreylee@gmail.com>, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: bryan.wu@analog.com, "David Howells" <dhowells@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965657AbXDIPo5@vger.kernel.org>
In-Reply-To: <1176112223.17975.8.camel@roc-desktop>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 9 Apr 2007 05:50, Wu, Bryan pondered:
> On Mon, 2007-04-09 at 11:01 +0800, Aubrey Li wrote:
> > The option CONFIG_PACKET_MMAP should depend on MMU.
> >
> > Signed-off-by: Aubrey.Li <aubreylee@gmail.com>
> > ---
> >  net/packet/Kconfig |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/net/packet/Kconfig b/net/packet/Kconfig
> > index 34ff93f..959c272 100644
> > --- a/net/packet/Kconfig
> > +++ b/net/packet/Kconfig
> > @@ -17,7 +17,7 @@ config PACKET
> >
> >  config PACKET_MMAP
> >  	bool "Packet socket: mmapped IO"
> > -	depends on PACKET
> > +	depends on PACKET && MMU
> >  	help
> >  	  If you say Y here, the Packet protocol driver will use an IO
> >  	  mechanism that results in faster communication.
>
> Yeah, this is a bug found on blackfin arch and it is also for other
> NOMMU arch. Is there any solution for this? We think Aubrey's idea
> works.
>

I would hardly say that disabling a feature should be classified as "works". 

"works" would be re-writing packet/af_packet.c:packet_mmap() so it doesn't use 
vm_insert_page (which I think is the major/only problem) or putting some 
proper #ifdef MMU to get the intended functionality.

David - I know you have been reworking the noMMU vma handling - is there a 
solution to vm_insert_page?

-Robin
