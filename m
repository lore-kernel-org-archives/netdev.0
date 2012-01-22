From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] virtio: correct the memory barrier in
	virtqueue_kick_prepare()
Date: Mon, 23 Jan 2012 10:04:17 +1030
Message-ID: <87y5szfh1i.fsf@rustcorp.com.au>
References: <20120120081658.50747.10625.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120120081708.50747.60241.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120122114757.GD27222@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120122114757.GD27222@redhat.com>
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

On Sun, 22 Jan 2012 13:47:57 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Fri, Jan 20, 2012 at 04:17:08PM +0800, Jason Wang wrote:
> > Use virtio_mb() to make sure the available index to be exposed before
> > checking the the avail event. Otherwise we may get stale value of
> > avail event in guest and never kick the host after.
> > 
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Good catch.
> Note: this fixes a bug introduced by ee7cd8981e15bcb365fc762afe3fc47b8242f630.

Indeed, great catch.  It replaces the missing barrier, and after some
careful thought I've convinced myself that it is necessary for both the
avail index and flag cases.

> >  	START_USE(vq);
> > -	/* Descriptors and available array need to be set before we expose the
> > -	 * new available array entries. */
> > -	virtio_wmb(vq);
> > +	/* We need expose available array entries before checking avail
> 
> Nit:
> We need expose -> Need to expose
> 
> > +	 * event. */
> > +	virtio_mb(vq);

Fixed typo and applied.

Thanks,
Rusty.
