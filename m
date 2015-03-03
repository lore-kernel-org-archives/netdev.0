From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: only allow UFO for packets from SOCK_DGRAM
 sockets
Date: Mon, 02 Mar 2015 22:19:59 -0500 (EST)
Message-ID: <20150302.221959.29477396151658670.davem@davemloft.net>
References: <20150302172711.6BCE4A0B46@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150302172711.6BCE4A0B46@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon,  2 Mar 2015 18:27:11 +0100 (CET)

> If an over-MTU UDP datagram is sent through a SOCK_RAW socket to a
> UFO-capable device, ip_ufo_append_data() sets skb->ip_summed to
> CHECKSUM_PARTIAL unconditionally as all GSO code assumes transport layer
> checksum is to be computed on segmentation. However, in this case,
> skb->csum_start and skb->csum_offset are never set as raw socket
> transmit path bypasses udp_send_skb() where they are usually set. As a
> result, driver may access invalid memory when trying to calculate the
> checksum and store the result (as observed in virtio_net driver).
> 
> Moreover, the very idea of modifying the userspace provided UDP header
> is IMHO against raw socket semantics (I wasn't able to find a document
> clearly stating this or the opposite, though). And while allowing
> CHECKSUM_NONE in the UFO case would be more efficient, it would be a bit
> too intrusive change just to handle a corner case like this. Therefore
> disallowing UFO for packets from SOCK_DGRAM seems to be the best option.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Seems reasonable to me, applied, thanks!
