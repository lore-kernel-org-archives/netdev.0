From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 26/42] vhost/net: force len for TX to host endian
Date: Wed, 26 Nov 2014 17:01:39 +0200
Message-ID: <20141126150139.GB9359@redhat.com>
References: <1416933600-21398-1-git-send-email-mst@redhat.com>
	<1416933600-21398-27-git-send-email-mst@redhat.com>
	<20141126153102.3f5b8fc9.cornelia.huck@de.ibm.com>
	<20141126144400.GA8086@redhat.com>
	<20141126155440.4f49b70f.cornelia.huck@de.ibm.com>
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
In-Reply-To: <20141126155440.4f49b70f.cornelia.huck@de.ibm.com>
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

On Wed, Nov 26, 2014 at 03:54:40PM +0100, Cornelia Huck wrote:
> On Wed, 26 Nov 2014 16:44:00 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Wed, Nov 26, 2014 at 03:31:02PM +0100, Cornelia Huck wrote:
> > > On Tue, 25 Nov 2014 18:43:14 +0200
> > > "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > > 
> > > > We use native endian-ness internally but never
> > > > expose it to guest.
> > > > 
> > > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > > ---
> > > >  drivers/vhost/net.c | 10 +++++-----
> > > >  1 file changed, 5 insertions(+), 5 deletions(-)
> > > > 
> > > > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > > > index 8dae2f7..dce5c58 100644
> > > > --- a/drivers/vhost/net.c
> > > > +++ b/drivers/vhost/net.c
> > > > @@ -48,15 +48,15 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
> > > >   * status internally; used for zerocopy tx only.
> > > >   */
> > > >  /* Lower device DMA failed */
> > > > -#define VHOST_DMA_FAILED_LEN	3
> > > > +#define VHOST_DMA_FAILED_LEN	((__force __virtio32)3)
> > > >  /* Lower device DMA done */
> > > > -#define VHOST_DMA_DONE_LEN	2
> > > > +#define VHOST_DMA_DONE_LEN	((__force __virtio32)2)
> > > >  /* Lower device DMA in progress */
> > > > -#define VHOST_DMA_IN_PROGRESS	1
> > > > +#define VHOST_DMA_IN_PROGRESS	((__force __virtio32)1)
> > > >  /* Buffer unused */
> > > > -#define VHOST_DMA_CLEAR_LEN	0
> > > > +#define VHOST_DMA_CLEAR_LEN	((__force __virtio32)0)
> > > 
> > > I find these constants a bit confusing: What does __virtio32 mean
> > > without the context of a vq or device?
> > > 
> > > > 
> > > > -#define VHOST_DMA_IS_DONE(len) ((len) >= VHOST_DMA_DONE_LEN)
> > > > +#define VHOST_DMA_IS_DONE(len) ((__force u32)(len) >= (__force u32)VHOST_DMA_DONE_LEN)
> > > 
> > > And here you cast it to a plain u32 again.
> > > 
> > > I looked at the final code, and you seem either to use the above
> > > constants for .len or do a cpu_to_vhost32(). Wouldn't you need to
> > > convert the constants as well?
> > 
> > I tried to explain it in the commit message.
> > It's a hack in vhost: it keeps virtio used structure in host
> > memory, but abuses length field for internal housekeeping.
> > This works because length in used ring for tx is always 0.
> 
> Ah, ok. It might make sense to add this explanation to the patch :)

Absolutely.
