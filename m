From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next rfc v7 2/3] virtio_net: multiqueue support
Date: Tue, 4 Dec 2012 09:35:03 +0200
Message-ID: <20121204073503.GB7499@redhat.com>
References: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
	<1354011360-39479-3-git-send-email-jasowang@redhat.com>
	<20121203101436.GB23009@redhat.com> <50BC7F59.301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <50BC7F59.301@redhat.com>
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

On Mon, Dec 03, 2012 at 06:30:49PM +0800, Jason Wang wrote:
> On 12/03/2012 06:14 PM, Michael S. Tsirkin wrote:
> > On Tue, Nov 27, 2012 at 06:15:59PM +0800, Jason Wang wrote:
> >> > -	if (!try_fill_recv(&vi->rq, GFP_KERNEL))
> >> > -		schedule_delayed_work(&vi->rq.refill, 0);
> >> > +	for (i = 0; i < vi->max_queue_pairs; i++)
> >> > +		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
> >> > +			schedule_delayed_work(&vi->rq[i].refill, 0);
> >> >  
> >> >  	mutex_lock(&vi->config_lock);
> >> >  	vi->config_enable = true;
> >> >  	mutex_unlock(&vi->config_lock);
> >> >  
> >> > +	BUG_ON(virtnet_set_queues(vi));
> >> > +
> >> >  	return 0;
> >> >  }
> >> >  #endif
> > Also crashing on device nack of command is also not nice.
> > In this case it seems we can just switch to
> > single-queue mode which should always be safe.
> 
> Not sure it's safe. It depends on the reason why this call fails. If we
> left a state that the driver only use single queue but the device use
> multi queues, we may still lost the network.

Looks like we won't: napi will stay enabled on all queues
so we will process incoming packets.

-- 
MST
