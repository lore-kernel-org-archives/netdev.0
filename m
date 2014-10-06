From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 09/16] virtio-net: drop config_mutex
Date: Mon, 6 Oct 2014 15:01:23 +0300
Message-ID: <20141006120123.GA26337@redhat.com>
References: <1412525038-15871-1-git-send-email-mst@redhat.com>
	<1412525038-15871-10-git-send-email-mst@redhat.com>
	<20141006135610.537c263b.cornelia.huck@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141006135610.537c263b.cornelia.huck@de.ibm.com>
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

On Mon, Oct 06, 2014 at 01:56:10PM +0200, Cornelia Huck wrote:
> On Sun, 5 Oct 2014 19:07:16 +0300
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > config_mutex served two purposes: prevent multiple concurrent config
> > change handlers, and synchronize access to config_enable flag.
> > 
> > Since commit dbf2576e37da0fcc7aacbfbb9fd5d3de7888a3c1
> >     workqueue: make all workqueues non-reentrant
> > all workqueues are non-reentrant, and config_enable
> > is now gone.
> > 
> > Get rid of the unnecessary lock.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  drivers/net/virtio_net.c | 7 +------
> >  1 file changed, 1 insertion(+), 6 deletions(-)
> > 
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index fa17afa..d80fef4 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> 
> > @@ -1430,7 +1426,7 @@ static void virtnet_config_changed_work(struct work_struct *work)
> >  		netif_tx_stop_all_queues(vi->dev);
> >  	}
> >  done:
> > -	mutex_unlock(&vi->config_lock);
> > +	return;
> >  }
> > 
> >  static void virtnet_config_changed(struct virtio_device *vdev)
> 
> I'd probably return directly in the remaining 'goto done;' cases, but still
> 
> Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>

Yes: this is exactly what
[PATCH 11/16] virtio_net: minor cleanup
does

-- 
MST
