From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 24/42] virtio_net: enable v1.0 support
Date: Wed, 26 Nov 2014 15:28:52 +0200
Message-ID: <20141126132852.GB5127@redhat.com>
References: <1416933600-21398-1-git-send-email-mst@redhat.com>
	<1416933600-21398-25-git-send-email-mst@redhat.com>
	<20141126140857.6ff85e4b.cornelia.huck@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rusty@au1.ibm.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141126140857.6ff85e4b.cornelia.huck@de.ibm.com>
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

On Wed, Nov 26, 2014 at 02:08:57PM +0100, Cornelia Huck wrote:
> On Tue, 25 Nov 2014 18:43:06 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > Now that we have completed 1.0 support, enable it in our driver.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  drivers/net/virtio_net.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> 
> Hm. The spec states that mac is driver-writable in the legacy case.
> Don't we need to fence writing it in virtnet_set_mac_address() in the
> virtio 1.0 case?

You are right. I'll add a patch to fix that one: we
should return -EOPNOTSUPP unless
	VIRTIO_NET_F_CTRL_MAC_ADDR or
	VERSION_1 is clear and VIRTIO_NET_F_MAC is set.
