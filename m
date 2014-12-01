From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH v7 31/46] vhost: virtio 1.0 endian-ness support
Date: Mon, 1 Dec 2014 13:42:47 +0100
Message-ID: <20141201134247.55e68161.cornelia.huck@de.ibm.com>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
	<1417359787-10138-32-git-send-email-mst@redhat.com>
	<20141201133353.0bbaa2e1.cornelia.huck@de.ibm.com>
	<20141201123701.GB17958@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141201123701.GB17958@redhat.com>
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

On Mon, 1 Dec 2014 14:37:01 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Mon, Dec 01, 2014 at 01:33:53PM +0100, Cornelia Huck wrote:
> > On Sun, 30 Nov 2014 17:11:49 +0200
> > "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > 
> > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > ---
> > >  drivers/vhost/vhost.c | 93 +++++++++++++++++++++++++++++++--------------------
> > >  1 file changed, 56 insertions(+), 37 deletions(-)
> > > 
> > 
> > > @@ -1113,18 +1120,19 @@ static int get_indirect(struct vhost_virtqueue *vq,
> > >  {
> > >  	struct vring_desc desc;
> > >  	unsigned int i = 0, count, found = 0;
> > > +	u32 len = vhost32_to_cpu(vq, indirect->len);
> > >  	int ret;
> > > 
> > >  	/* Sanity check */
> > > -	if (unlikely(indirect->len % sizeof desc)) {
> > > +	if (unlikely(len % sizeof desc)) {
> > >  		vq_err(vq, "Invalid length in indirect descriptor: "
> > >  		       "len 0x%llx not multiple of 0x%zx\n",
> > > -		       (unsigned long long)indirect->len,
> > > +		       (unsigned long long)vhost32_to_cpu(vq, indirect->len),
> > 
> > Can't you use len here?
> 
> Not if I want error message to be readable.

Huh? Both have the same value.
