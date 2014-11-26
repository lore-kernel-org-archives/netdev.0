From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 25/42] vhost: add memory access wrappers
Date: Wed, 26 Nov 2014 16:05:39 +0200
Message-ID: <20141126140539.GA5528@redhat.com>
References: <1416933600-21398-1-git-send-email-mst@redhat.com>
	<1416933600-21398-26-git-send-email-mst@redhat.com>
	<20141126145438.4421c00d.cornelia.huck@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, rusty@au1.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141126145438.4421c00d.cornelia.huck@de.ibm.com>
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

On Wed, Nov 26, 2014 at 02:54:38PM +0100, Cornelia Huck wrote:
> On Tue, 25 Nov 2014 18:43:10 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> "These wrappers are needed to handle virtio endianness conversions."
> 
> ?

yes, it's same as virtio ones. I'll add this text, thanks.

> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  drivers/vhost/vhost.h | 33 ++++++++++++++++++++++++++++++++-
> >  1 file changed, 32 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> > index 3eda654..b9032e8 100644
> > --- a/drivers/vhost/vhost.h
> > +++ b/drivers/vhost/vhost.h
> > @@ -174,6 +174,37 @@ enum {
> > 
> >  static inline int vhost_has_feature(struct vhost_virtqueue *vq, int bit)
> >  {
> > -	return vq->acked_features & (1 << bit);
> > +	return vq->acked_features & (1ULL << bit);
> 
> Should this hunk go into patch 28?

Well, this is needed here since 1 << 32 is not legal C.

I can move it - this means patch 28 will have to move earlier
in series though.



> > +}
