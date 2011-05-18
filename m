From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH 06/18] virtio_ring: avail event index interface
Date: Wed, 18 May 2011 09:38:24 +0930
Message-ID: <87wrhona4n.fsf@rustcorp.com.au>
References: <cover.1304541918.git.mst@redhat.com>
	<b00ef5d572ec9bc3b884c496025512abc1f14349.1304541919.git.mst@redhat.com>
	<87aaewh5pg.fsf@rustcorp.com.au>
	<20110515124727.GA24932@redhat.com>
	<87k4drduzs.fsf@rustcorp.com.au>
	<20110517060052.GB26989@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20110517060052.GB26989-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 17 May 2011 09:00:52 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, May 16, 2011 at 03:53:19PM +0930, Rusty Russell wrote:
> > On Sun, 15 May 2011 15:47:27 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > On Mon, May 09, 2011 at 01:43:15PM +0930, Rusty Russell wrote:
> > > > On Wed, 4 May 2011 23:51:19 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > > >  #define VIRTIO_RING_F_USED_EVENT_IDX	29
> > > > > +/* The Host publishes the avail index for which it expects a kick
> > > > > + * at the end of the used ring. Guest should ignore the used->flags field. */
> > > > > +#define VIRTIO_RING_F_AVAIL_EVENT_IDX	32
> > > > 
> > > > Are you really sure we want to separate the two?  Seems a little simpler
> > > > to have one bit to mean "we're publishing our threshold".  For someone
> > > > implementing this from scratch, it's a little simpler.
> > > > 
> > > > Or are there cases where the old style makes more sense?
> > > > 
> > > > Thanks,
> > > > Rusty.
> > > 
> > > Hmm, it makes debugging easier as each side can disable
> > > publishing separately - I used it all the time when I saw
> > > e.g. networking stuck to guess whether I need to investigate the
> > > interrupt or the exit handling.
> > > 
> > > But I'm not hung up on this.
> > > 
> > > Let me know pls.
> > 
> > If we combine them into one, then these patches no longer depend on
> > the feature bit expansion, which is worthwhile (though I'll take both).
> > 
> > Thanks,
> > Rusty.
> 
> Yes, I know. But if we do expand feature bits anyway, for debugging
> and profiling if nothing else it's useful to have them separate ...
> If you take both why does the order matter?

Damage control.  Then if something breaks, it doesn't break everything.

Cheers,
Rusty.
