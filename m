From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 RFC 0/4] virtio and vhost-net capacity
	handling
Date: Tue, 7 Jun 2011 19:08:30 +0300
Message-ID: <20110607160830.GB17581@redhat.com>
References: <cover.1307029008.git.mst@redhat.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1307029008.git.mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Thu, Jun 02, 2011 at 06:42:35PM +0300, Michael S. Tsirkin wrote:
> OK, here's a new attempt to use the new capacity api.  I also added more
> comments to clarify the logic.  Hope this is more readable.  Let me know
> pls.
> 
> This is on top of the patches applied by Rusty.
> 
> Warning: untested. Posting now to give people chance to
> comment on the API.

OK, this seems to have survived some testing so far,
after I dropped patch 4 and fixed build for patch 3
(build fixup patch sent in reply to the original).

I'll be mostly offline until Sunday, would appreciate
testing reports.

git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git
virtio-net-xmit-polling-v2
git://git.kernel.org/pub/scm/linux/kernel/git/mst/qemu-kvm.git
virtio-net-event-idx-v3

Thanks!

> Changes from v1:
> - fix comment in patch 2 to correct confusion noted by Rusty
> - rewrite patch 3 along the lines suggested by Rusty
>   note: it's not exactly the same but I hope it's close
>   enough, the main difference is that mine does limited
>   polling even in the unlikely xmit failure case.
> - added a patch to not return capacity from add_buf
>   it always looked like a weird hack
> 
> Michael S. Tsirkin (4):
>   virtio_ring: add capacity check API
>   virtio_net: fix tx capacity checks using new API
>   virtio_net: limit xmit polling
>   Revert "virtio: make add_buf return capacity remaining:
> 
>  drivers/net/virtio_net.c     |  111 ++++++++++++++++++++++++++----------------
>  drivers/virtio/virtio_ring.c |   10 +++-
>  include/linux/virtio.h       |    7 ++-
>  3 files changed, 84 insertions(+), 44 deletions(-)
> 
> -- 
> 1.7.5.53.gc233e
