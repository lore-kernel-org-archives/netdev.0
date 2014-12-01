From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 30/46] vhost/net: force len for TX to host endian
Date: Mon, 1 Dec 2014 14:33:34 +0200
Message-ID: <20141201123334.GB17875@redhat.com>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
	<1417359787-10138-31-git-send-email-mst@redhat.com>
	<20141201132051.4ab028d9.cornelia.huck@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141201132051.4ab028d9.cornelia.huck@de.ibm.com>
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

On Mon, Dec 01, 2014 at 01:20:51PM +0100, Cornelia Huck wrote:
> On Sun, 30 Nov 2014 17:11:44 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > vhost/net keeps a copy of some used ring but (ab)uses length
> > field for internal house-keeping. This works because
> > for tx used length is always 0.
> > Suppress sparse errors: we use native endian-ness internally but never
> > expose it to guest.
> 
> I admit that I find this patch description hard to read :)
> 
> 
> "vhost/net keeps a copy of the used ring in host memory but (ab)uses
> the length field for internal house-keeping. This works because the
> length in the used ring for tx is always 0. In order to suppress sparse
> errors, we need to force native endianness."
> 
> ?

Yes. Add to this "These values are never exposed to guest."

> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Reviewed-by: Jason Wang <jasowang@redhat.com>
> > ---
> >  drivers/vhost/net.c | 10 +++++-----
> >  1 file changed, 5 insertions(+), 5 deletions(-)
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 8dae2f7..dce5c58 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -48,15 +48,15 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
> >   * status internally; used for zerocopy tx only.
> >   */
> >  /* Lower device DMA failed */
> > -#define VHOST_DMA_FAILED_LEN	3
> > +#define VHOST_DMA_FAILED_LEN	((__force __virtio32)3)
> >  /* Lower device DMA done */
> > -#define VHOST_DMA_DONE_LEN	2
> > +#define VHOST_DMA_DONE_LEN	((__force __virtio32)2)
> >  /* Lower device DMA in progress */
> > -#define VHOST_DMA_IN_PROGRESS	1
> > +#define VHOST_DMA_IN_PROGRESS	((__force __virtio32)1)
> >  /* Buffer unused */
> > -#define VHOST_DMA_CLEAR_LEN	0
> > +#define VHOST_DMA_CLEAR_LEN	((__force __virtio32)0)
> > 
> > -#define VHOST_DMA_IS_DONE(len) ((len) >= VHOST_DMA_DONE_LEN)
> > +#define VHOST_DMA_IS_DONE(len) ((__force u32)(len) >= (__force u32)VHOST_DMA_DONE_LEN)
> > 
> >  enum {
> >  	VHOST_NET_FEATURES = VHOST_FEATURES |
