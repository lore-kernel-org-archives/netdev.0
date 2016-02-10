From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 1/2] vhost: helpers to enable/disable vring endianness
Date: Wed, 10 Feb 2016 14:12:55 +0100
Message-ID: <20160210141255.5466f8e0.cornelia.huck@de.ibm.com>
References: <20160113170934.23705.62626.stgit@bahia.huguette.org>
	<20160113170941.23705.93915.stgit@bahia.huguette.org>
	<20160210131723-mutt-send-email-mst@redhat.com>
	<20160210131134.747352bd@bahia.huguette.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Greg Kurz <gkurz@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160210131134.747352bd@bahia.huguette.org>
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

On Wed, 10 Feb 2016 13:11:34 +0100
Greg Kurz <gkurz@linux.vnet.ibm.com> wrote:

> On Wed, 10 Feb 2016 13:21:22 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Wed, Jan 13, 2016 at 06:09:41PM +0100, Greg Kurz wrote:

> > > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > > index ad2146a9ab2d..e02e06755ab7 100644
> > > --- a/drivers/vhost/vhost.c
> > > +++ b/drivers/vhost/vhost.c
> > > @@ -43,11 +43,16 @@ enum {
> > >  #define vhost_avail_event(vq) ((__virtio16 __user *)&vq->used->ring[vq->num])
> > >  
> > >  #ifdef CONFIG_VHOST_CROSS_ENDIAN_LEGACY
> > > -static void vhost_vq_reset_user_be(struct vhost_virtqueue *vq)
> > > +static void vhost_disable_user_be(struct vhost_virtqueue *vq)
> > >  {
> > >  	vq->user_be = !virtio_legacy_is_little_endian();
> > >  }
> > >    
> > 
> > Hmm this doesn't look like an improvement to me.
> > What does it mean to disable big endian? Make it little endian?
> 
> The default behavior for the device is native endian.
> 
> The SET_VRING_ENDIAN ioctl is used to make the device big endian
> on little endian hosts, hence "enabling" cross-endian mode...
> 
> > Existing reset seems to make sense.
> > 
> 
> ... and we "disable" cross-endian mode on reset.
> 
> > > +static void vhost_enable_user_be(struct vhost_virtqueue *vq, bool user_be)
> > > +{
> > > +	vq->user_be = user_be;
> > > +}
> > > +  
> > 
> > And this is maybe "init_user_be"?
> > 
> 
> Anyway I don't mind changing the names to reset/init_user_be if you think it
> is clearer.

FWIW, I find the enable/disable terminology less confusing.
