From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Mon, 15 May 2006 21:18:43 -0700 (PDT)
Message-ID: <20060515.211843.82450846.davem@davemloft.net>
References: <E1FfnZP-0003St-00@gondolin.me.apana.org.au>
	<44692847.4080100@trash.net>
	<4469294D.6010509@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, shemminger@osdl.org,
	ranjitm@google.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751261AbWEPETr@vger.kernel.org>
To: kaber@trash.net
In-Reply-To: <4469294D.6010509@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 16 May 2006 03:22:21 +0200

> Patrick McHardy wrote:
> > 3) Clone the skb and have dev_queue_xmit_nit() consume it.
> > 
> > That should actually be pretty easy.
> 
> On second thought, thats not so great either. netdev_nit
> just globally signals that there are some taps, but we
> don't know if they're interested in a specific packet.

Yes, and all of these issues coming up are why we do the
dev_queue_xmit_nit() before not after we try to give it to the device.

Even the "NIT done" bit doesn't work, for cases like ICMP replies
which can reuse the SKB received, over loopback.  Sure we can try to
forcefully clear the bit everywhere we reuse buffers for replies like
that, but I wish anyone trying to implement that the best of luck
finding all spots successfully.

To be honest, I don't think this bug is worth all the energy we are
trying to put into fixing it.

We get a double packet when the spinlock is hit, big deal.
