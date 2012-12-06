From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv5] virtio-spec: virtio network device RFS support
Date: Thu, 6 Dec 2012 22:03:23 +0000
Message-ID: <1354831403.2828.63.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121203105843.GA26194@redhat.com>
	 <1354739966.2655.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <20121206081320.GD10837@redhat.com>
	 <1354824194.2828.6.camel@bwh-desktop.uk.solarflarecom.com>
	 <20121206202921.GB4340@redhat.com>
	 <1354827239.2828.36.camel@bwh-desktop.uk.solarflarecom.com>
	 <20121206210132.GB6576@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, <rusty@rustcorp.com.au>,
	<virtualization@lists.linux-foundation.org>,
	<netdev@vger.kernel.org>, <kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20121206210132.GB6576@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-12-06 at 23:01 +0200, Michael S. Tsirkin wrote:
> On Thu, Dec 06, 2012 at 08:53:59PM +0000, Ben Hutchings wrote:
> > On Thu, 2012-12-06 at 22:29 +0200, Michael S. Tsirkin wrote:
> > > On Thu, Dec 06, 2012 at 08:03:14PM +0000, Ben Hutchings wrote:
> > [...]
> > > > Since this doesn't seem to be intended to have *any* connection with the
> > > > existing core networking feature called RFS, perhaps you could find a
> > > > different name for it.
> > > > 
> > > > Ben.
> > > 
> > > 
> > > Ah I see what you mean. We started out calling this feature "multiqueue"
> > > Rusty suggested "RFS" since it gives similar functionality to RFS but in
> > > device: it has receive steering logic per flow as part of the device.
> > 
> > The name is quite generic, but in the context of Linux it has so far
> > been used for a specific software feature and not as a generic name for
> > flow steering by hardware (or drivers).  The existing documentation
> > (Documentation/networking/scaling.txt) states quite clearly that 'RFS'
> > means that specific software implementation (with optional driver
> > integration) and configuration interface.
> >
> > > Maybe simply adding a statement similar to the one above would be
> > > sufficient to avoid confusion?
> > 
> > No, I don't think it's sufficient.  We have documentation that says how
> > to configure 'RFS', and you're proposing to add a very similar feature
> > called 'RFS' that is configured differently.  No matter how clearly you
> > distinguish them in new documentation, this will make the old
> > documentation confusing.
> > 
> > Ben.
> 
> I don't mind, renaming is just s/RFS/whatever/ away -
> how should hardware call this in your opinion?

If by 'this' you mean the use of perfect filters or a large hash table
to select the RX queue per flow, then 'flow steering'.

But that is usually combined with the fall-back of a simple mapping from
hash to queue ('RSS' or 'flow hashing') in case there is no specific
queue selection yet, which I can see tun has.  And you're specifying
multiple transmit queues too.  If you want a name for the whole set of
features involved, I don't see any better name than 'multiqueue'/'MQ'.

If you want a name for this specific flow steering mechanism, add some
distinguishing adjective(s) like 'virtual' or 'automatic'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

