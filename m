From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] virtio/vhost: cross endian support
Date: Tue, 7 Jul 2015 19:51:45 +0300
Message-ID: <20150707195012-mutt-send-email-mst@redhat.com>
References: <20150701113150-mutt-send-email-mst@redhat.com>
	<CA+55aFwE+vO2xevQ5jpyC0uJ7gASDwMS4=aDb=78RsJNA-wN1Q@mail.gmail.com>
	<20150702071412-mutt-send-email-mst@redhat.com>
	<20150702111256.13f8ea71@bahia.local>
	<20150702112809-mutt-send-email-mst@redhat.com>
	<20150707183653.462b5df0@thh440s>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: KVM list <kvm@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Thomas Huth <thuth@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20150707183653.462b5df0@thh440s>
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

On Tue, Jul 07, 2015 at 06:36:53PM +0200, Thomas Huth wrote:
> On Thu, 2 Jul 2015 11:32:52 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Thu, Jul 02, 2015 at 11:12:56AM +0200, Greg Kurz wrote:
> > > On Thu, 2 Jul 2015 08:01:28 +0200
> > > "Michael S. Tsirkin" <mst@redhat.com> wrote:
> ...
> > > > Yea, well - support for legacy BE guests on the new LE hosts is
> > > > exactly the motivation for this.
> > > > 
> > > > I dislike it too, but there are two redeeming properties that
> > > > made me merge this:
> > > > 
> > > > 1.  It's a trivial amount of code: since we wrap host/guest accesses
> > > >     anyway, almost all of it is well hidden from drivers.
> > > > 
> > > > 2.  Sane platforms would never set flags like VHOST_CROSS_ENDIAN_LEGACY -
> > > >     and when it's clear, there's zero overhead (as some point it was
> > > >     tested by compiling with and without the patches, got the same
> > > >     stripped binary).
> > > > 
> > > > Maybe we could create a Kconfig symbol to enforce point (2): prevent
> > > > people from enabling it e.g. on x86. I will look into this - but it can
> > > > be done by a patch on top, so I think this can be merged as is.
> > > > 
> > > 
> > > This cross-endian *oddity* is targeting PowerPC book3s_64 processors... I
> > > am not aware of any other users. Maybe create a symbol that would
> > > be only selected by PPC_BOOK3S_64 ?
> > 
> > I think some ARM systems are trying to support cross-endian
> > configurations as well.
> > 
> > Besides that, yes, this is more or less what I had in mind.
> 
> Would something simple like this already do the job:
> 
> diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
> --- a/drivers/vhost/Kconfig
> +++ b/drivers/vhost/Kconfig
> @@ -35,6 +35,7 @@ config VHOST
>  
>  config VHOST_CROSS_ENDIAN_LEGACY
>  	bool "Cross-endian support for vhost"
> +	depends on KVM_BOOK3S_64 || KVM_ARM_HOST
>  	default n
>  	---help---
>  	  This option allows vhost to support guests with a different byte
> 
> ?

Do all ARM hosts support this dynamic endian-ness?

> If that looks acceptable, I can submit a proper patch if you like.
> 
>  Thomas

I think I prefer some kind of symbol defined by these arches,
so I don't get to maintain an arch list in vhost.

-- 
MST
