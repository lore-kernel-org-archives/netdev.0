From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next RFC V2 PATCH 0/5] Multiqueue support in tun/tap
Date: Mon, 19 Sep 2011 15:45:51 +0100
Message-ID: <1316443551.2764.9.camel@bwh-desktop>
References: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, eric.dumazet@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net,
	kvm@vger.kernel.org, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	mirq-linux@rere.qmqm.pl, joe@perches.com, shemminger@vyatta.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-09-17 at 14:02 +0800, Jason Wang wrote:
[...]
> 2 Current implementation may also get regression for single session
> packet transmission.
> 
> The reason is packets from each flow were not handled by the same
> queue/vhost thread.
> 
> Various method could be done to handle this:
> 
> 2.1 hack the guest driver, and store the queue index into the rxhash and
> use it when choosing tx in guest. This need some hack to store the
> rxhash into sk and pass it in to skb again in
> skb_orphan_try(). sk_rxhash is only used by RPS now, so some more
> clean method is needed.
[...]

I have previously suggested doing this as a general rule.  However, I
now think we can do much better with accelerated RFS and automatic XPS
(but the latter is not yet implemented).  For virtio_net, accelerated
RFS would effectively push the guest's RFS socket map out to the host.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
