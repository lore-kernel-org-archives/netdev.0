From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] virtio/vhost: cross endian support
Date: Fri, 3 Jul 2015 09:59:01 +0200
Message-ID: <20150703095637-mutt-send-email-mst@redhat.com>
References: <20150701113150-mutt-send-email-mst@redhat.com>
 <CA+55aFwE+vO2xevQ5jpyC0uJ7gASDwMS4=aDb=78RsJNA-wN1Q@mail.gmail.com>
 <20150702071412-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: KVM list <kvm@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	gkurz@linux.vnet.ibm.com, kraxel@redhat.com, thuth@redhat.com,
	david@gibson.dropbear.id.au
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150702071412-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 02, 2015 at 08:01:28AM +0200, Michael S. Tsirkin wrote:
> On Wed, Jul 01, 2015 at 12:02:50PM -0700, Linus Torvalds wrote:
> > On Wed, Jul 1, 2015 at 2:31 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > > virtio/vhost: cross endian support
> > 
> > Ugh. Does this really have to be dynamic?
> > 
> > Can't virtio do the sane thing, and just use a _fixed_ endianness?
> > 
> > Doing a unconditional byte swap is faster and simpler than the crazy
> > conditionals. That's true regardless of endianness, but gets to be
> > even more so if the fixed endianness is little-endian, since BE is
> > not-so-slowly fading from the world.
> > 
> >                Linus
> 
> Yea, well - support for legacy BE guests on the new LE hosts is
> exactly the motivation for this.
> 
> I dislike it too, but there are two redeeming properties that
> made me merge this:
> 
> 1.  It's a trivial amount of code: since we wrap host/guest accesses
>     anyway, almost all of it is well hidden from drivers.
> 
> 2.  Sane platforms would never set flags like VHOST_CROSS_ENDIAN_LEGACY -
>     and when it's clear, there's zero overhead (as some point it was
>     tested by compiling with and without the patches, got the same
>     stripped binary).
> 
> Maybe we could create a Kconfig symbol to enforce point (2): prevent
> people from enabling it e.g. on x86. I will look into this - but it can
> be done by a patch on top, so I think this can be merged as is.

Linus, could you please clarify whether making the
feature depend on the cross-endian guest support
would address your comment, and whether you think
this can be merged as is, and the dependency added
after -rc1?


> Or do you know of someone using kernel with all config options enabled
> undiscriminately?
> 
> Thanks,
> 
> -- 
> MST
