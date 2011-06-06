From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCHv2 RFC 0/4] virtio and vhost-net capacity
	handling
Date: Mon, 06 Jun 2011 13:09:35 +0930
Message-ID: <87fwnniq6f.fsf@rustcorp.com.au>
References: <cover.1307029008.git.mst@redhat.com>
	<20110602171721.GA13215@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20110602171721.GA13215-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Thu, 2 Jun 2011 20:17:21 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, Jun 02, 2011 at 06:42:35PM +0300, Michael S. Tsirkin wrote:
> > OK, here's a new attempt to use the new capacity api.  I also added more
> > comments to clarify the logic.  Hope this is more readable.  Let me know
> > pls.
> > 
> > This is on top of the patches applied by Rusty.
> > 
> > Warning: untested. Posting now to give people chance to
> > comment on the API.
> > 
> > Changes from v1:
> > - fix comment in patch 2 to correct confusion noted by Rusty
> > - rewrite patch 3 along the lines suggested by Rusty
> >   note: it's not exactly the same but I hope it's close
> >   enough, the main difference is that mine does limited
> >   polling even in the unlikely xmit failure case.
> > - added a patch to not return capacity from add_buf
> >   it always looked like a weird hack
> > 
> > Michael S. Tsirkin (4):
> >   virtio_ring: add capacity check API
> >   virtio_net: fix tx capacity checks using new API
> >   virtio_net: limit xmit polling
> >   Revert "virtio: make add_buf return capacity remaining:
> > 
> >  drivers/net/virtio_net.c     |  111 ++++++++++++++++++++++++++----------------
> >  drivers/virtio/virtio_ring.c |   10 +++-
> >  include/linux/virtio.h       |    7 ++-
> >  3 files changed, 84 insertions(+), 44 deletions(-)
> > 
> > -- 
> > 1.7.5.53.gc233e
> 
> 
> And just FYI, here's a patch (on top) that I considered but
> decided against. This does a single get_buf before
> xmit. I thought it's not really needed as the capacity
> check in add_buf is relatively cheap, and we removed
> the kick in xmit_skb. But the point is that the loop
> will now be easy to move around if someone manages
> to show this benefits speed (which I doubt).

Agreed.  The other is clearer.

I like the approach these patches take.  Testing is required, but I
think the final result is a neater driver than the current one, as well
as having nicer latency.

Thanks,
Rusty.
