From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: network performance degradation in virtio_net in 4.12-rc
Date: Mon, 22 May 2017 17:50:38 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1705221748420.24628@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1705221003450.20076@file01.intranet.prod.int.rdu2.redhat.com>
	<20170522203532-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170522203532-mutt-send-email-mst@kernel.org>
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



On Mon, 22 May 2017, Michael S. Tsirkin wrote:

> On Mon, May 22, 2017 at 10:25:19AM -0400, Mikulas Patocka wrote:
> > Hi
> > 
> > I see severe network performance degradation with the kernels 4.12-rc1 and 
> > 4.12-rc2 in the network virtio driver. Download rate drops down to about 
> > 100kB/s.
> > 
> > I bisected it and it is caused by patch 
> > d85b758f72b05a774045545f24d70980e3e9aac4 ("virtio_net: fix support for 
> > small rings"). When I revert this patch, the problem goes away.
> > 
> > The host is Debian Jessie with kernel 4.4.62, the guest is Debian Sid with 
> > kernel 4.12-rc.
> > 
> > Mikulas
> 
> Thanks for the report!
> I'm not sure what causes it on this host. I'll try to reproduce.
> Meanwhile, could you please locate this line of code:
> +               vi->rq[i].min_buf_len = mergeable_min_buf_len(vi, vi->rq[i].vq);
> 
> and add something like
> 	printk(KERN_ERR, "min buf = 0x%x expected 0x%x size 0x%x big %d\n",
> 	       vi->rq[i].min_buf_len, GOOD_PACKET_LEN,
> 	       virtqueue_get_vring_size(vi->rq[i].vq),
> 	       (int)vi->big_packets);
> 
> after it?
> Then boot and capture the output.
> 
> Thanks!

It prints one line "min buf = 0x101 expected 0x5ee size 0x100 big 1".

Mikulas
