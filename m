From: Chetan Kumar <shivakumar.chetan@gmail.com>
Subject: Re: Some query on ingress policing
Date: Fri, 18 Feb 2005 12:49:43 +0530
Message-ID: <17fe83cb050217231925c43a8e@mail.gmail.com>
References: <17fe83cb0502160349a4190d1@mail.gmail.com>
	 <17fe83cb05021616323c3dab@mail.gmail.com>
	 <7bca1cb5050217150642addd71@mail.gmail.com>
Reply-To: Chetan Kumar <shivakumar.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <7bca1cb5050217150642addd71@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yes, That is the point. Now since the ingress policing is done in
net_rx_action (i.e) after queueing the packet on the input queue, the
packet which was misbehaving would have used the queue resources. One
would drop the packet only after you clear the backlog queue, and a
greedy flow could potentially over-run the buffer of well behaved
flows.

Also another serious issues is that if I ever want to provide priority
for the VOIP traffic, that is not feasible since the backlog queue is
drained in a FIFO manner.


On Thu, 17 Feb 2005 17:06:13 -0600, Asim Shankar <asimshankar@gmail.com> wrote:
> > I was going thro the packet journey thro the network stack in Linux.
> > Now if I want enable ingress policing, it looks like packet
> > classification and policing should happen in netif_rx (i.e in the
> > interrupt context) before packet is queued on to the input queue am I
> > missing something.
> 
> My understanding is that ingress policing (the
> qdisc_ingress->enqueue() call) is done in the softint. See
> netif_receive_skb() for a call to ing_filter().
> 
> Alternatively, if CONFIG_NET_CLS_ACT=n and CONFIG_NETFILTER=y then the
> policing happens as an NF_IP_PRE_ROUTING netfilter hook instead.
> 
> Also, netif_rx() is not the single point of entry for skb's to the
> stack. NAPI drivers are polled for packets, so packets aren't always
> picked up from the NIC in the interrupt context.
> 
> Hope that helps,
> 
> -- Asim
>
