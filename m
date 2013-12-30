From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 11/20] net: packetengines: slight
 optimization of addr
Date: Sun, 29 Dec 2013 22:05:26 -0800
Message-ID: <1388383526.26796.21.camel@joe-AO722>
References: <52BE6D0D.9050301@huawei.com>
	 <52BED8ED.2040908@cogentembedded.com> <52BEEBD5.1040301@gmail.com>
	 <1388251380.24123.15.camel@joe-AO722> <52C0DCF7.6040402@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dthxman@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52C0DCF7.6040402@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-12-30 at 10:39 +0800, Ding Tianhong wrote:
> I don't understand packetengine NIC anymore, But I think the change is clearly,
> as your said, the broadcast check is enough here, did you mean that?
> 
> 	!is_broadcast_ether_addr((u8 *)(le32_to_cpu(yp->rx_ring_dma) +
> 						    entry * sizeof(struct yellowfin_desc)))

Not quite.  I meant this could be:

		u8 *addr = (u8 *)(unsigned long)le32_to_cpu(yp->rx_ring_dma) +
							    entry * sizeof(struct yellowfin_desc);

		if (!ether_addr_equal(addr, dev->dev_addr) &&
		    !is_broadcast_ether_addr(addr)) {
			etc...

but again, I think thus hardly matters and could just as well
be left alone.
