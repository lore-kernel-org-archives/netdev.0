From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: tun device - bug or feature? WAS(Re: IMQ / new Dummy device
	post.
Date: Mon, 26 Apr 2004 12:31:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1083007898.7788.276.camel@localhost>
References: <wazza.87ad18jbdl.fsf@message.id>
	 <1082427350.1034.70.camel@jzny.localdomain>
	 <wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
	 <wazza.87hdvddqxq.fsf@message.id>
	 <1082639764.1059.81.camel@jzny.localdomain>
	 <87oepjx65r.87n053x65r@87llknx65r.message.id>
	 <1082719745.1057.27.camel@jzny.localdomain>
	 <1082816083.1054.32.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, syrius.ml@no-log.org, Jeff Garzik <jgarzik@pobox.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082816083.1054.32.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-04-24 at 07:14, jamal wrote:
> Maxim,
> 
> When TUN_TUN_DEV is used, before the packet is injected into
> the netif_rx() only skb->mac.raw = skb->data is set; the other headers
> are not adjusted. Typically netdevs would do a
> skb_pull(skb,dev->hard_header_len) to make the adjustment.
> I have a feeling this is design intent thats why i didnt send you a
> patch. 
Well TUN does not have any hw headers so there is nothing to pull :).
Basically it does what ever PPP driver does. Which is

	skb_pull(skb, 2);       /* chop off protocol */
        skb->dev = ppp->dev;
        skb->protocol = htons(npindex_to_ethertype[npi]);
        skb->mac.raw = skb->data;
        netif_rx(skb);

Max
