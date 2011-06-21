From: Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: RFT: virtio_net: limit xmit polling
Date: Tue, 21 Jun 2011 10:23:22 -0500
Message-ID: <201106211023.24643.tahm@linux.vnet.ibm.com>
References: <20110619102700.GA11198@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	roprabhu-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20110619102700.GA11198-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Sunday, June 19, 2011 05:27:00 AM Michael S. Tsirkin wrote:
> OK, different people seem to test different trees.  In the hope to get
> everyone on the same page, I created several variants of this patch so
> they can be compared. Whoever's interested, please check out the
> following, and tell me how these compare:

I'm in the process of testing these patches.  Base and v0 are complete
and v1 is near complete with v2 to follow.  I'm testing with a variety
of TCP_RR and TCP_STREAM/TCP_MAERTS tests involving local guest-to-guest
tests and remote host-to-guest tests.  I'll post the results in the next
day or two when the tests finish.

Thanks,
Tom

> 
> kernel:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git
> 
> virtio-net-limit-xmit-polling/base - this is net-next baseline to test
> against virtio-net-limit-xmit-polling/v0 - fixes checks on out of capacity
> virtio-net-limit-xmit-polling/v1 - previous revision of the patch
> 		this does xmit,free,xmit,2*free,free
> virtio-net-limit-xmit-polling/v2 - new revision of the patch
> 		this does free,xmit,2*free,free
> 
> There's also this on top:
> virtio-net-limit-xmit-polling/v3 -> don't delay avail index update
> I don't think it's important to test this one, yet
> 
> Userspace to use: event index work is not yet merged upstream
> so the revision to use is still this:
> git://git.kernel.org/pub/scm/linux/kernel/git/mst/qemu-kvm.git
> virtio-net-event-idx-v3
