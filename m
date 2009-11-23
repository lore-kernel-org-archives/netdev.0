From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/1] Defer skb allocation for both mergeable buffers and big packets in virtio_net
Date: Mon, 23 Nov 2009 11:23:18 +1030
Message-ID: <200911231123.18898.rusty@rustcorp.com.au>
References: <1258697359.7416.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753930AbZKWAxS@vger.kernel.org>
In-Reply-To: <1258697359.7416.14.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Nov 2009 04:39:19 pm Shirley Ma wrote:
> Guest virtio_net receives packets from its pre-allocated vring 
> buffers, then it delivers these packets to upper layer protocols
> as skb buffs. So it's not necessary to pre-allocate skb for each
> mergable buffer, then frees it when it's useless. 
> 
> This patch has deferred skb allocation when receiving packets for
> both big packets and mergeable buffers. It reduces skb pre-allocations 
> and skb_frees.
> 
> Based on Mickael & Avi's suggestion. A destroy function has been created
> to push virtio free buffs to vring for unused pages, and used page private
> to maintain page list.
> 
> I didn't touch small packet skb allocation to avoid extra copies for small
> packets.
> 
> This patch has tested and measured against 2.6.32-rc5 git. It is built again
>  2.6.32-rc7 kernel. Tests have been done for small packets, big packets and
> mergeable buffers.
> 
> The single netperf TCP_STREAM performance improved for host to guest. 
> It also reduces UDP packets drop rate.
> 
> The netperf laptop results were:
> 
> mtu=1500
> netperf -H xxx -l 120
> 
> 		w/o patch	w/i patch (two runs)	
> guest to host:  3336.84Mb/s   3730.14Mb/s ~ 3582.88Mb/s
> 
> host to guest:  3165.10Mb/s   3370.39Mb/s ~ 3407.96Mb/s

Nice!

Is this using mergeable_rx_bufs?  Or just big_packets?

I'd like to drop big packet support from our driver, but I don't know
how many kvm hosts will not offer mergable rx bufs yet.  Anthony?

Thanks,
Rusty.
