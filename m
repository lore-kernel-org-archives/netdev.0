From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net,2/2] net: i40e: shut up uninitialized variable warnings
Date: Sun, 31 Jan 2016 15:59:17 +0100
Message-ID: <2154537.J75p8oY6mX@wuerfel>
References: <1453766332-43274-3-git-send-email-jeffrey.t.kirsher@intel.com> <56ACD7C6.1010808@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Vasily Averin <vvs@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:56696 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757218AbcAaO7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 09:59:49 -0500
In-Reply-To: <56ACD7C6.1010808@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 30 January 2016 18:33:26 Vasily Averin wrote:
> On 26.01.2016 02:58, Jeff Kirsher wrote:
> > From: Arnd Bergmann <arnd@arndb.de>
> > 
> > intel/i40e/i40e_txrx.c: In function 'i40e_xmit_frame_ring':
> > intel/i40e/i40e_txrx.c:2367:20: error: 'oiph' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > intel/i40e/i40e_txrx.c:2317:16: note: 'oiph' was declared here
> > intel/i40e/i40e_txrx.c:2367:17: error: 'oudph' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > intel/i40e/i40e_txrx.c:2316:17: note: 'oudph' was declared here
> 
> 2364                 if ((tx_ring->flags & I40E_TXR_FLAGS_OUTER_UDP_CSUM) &&
> 2365                     (l4_tunnel == I40E_TXD_CTX_UDP_TUNNELING)        &&
> 2366                     (*cd_tunneling & I40E_TXD_CTX_QW0_EXT_IP_MASK)) {
> 2367                         oudph->check = ~csum_tcpudp_magic(oiph->saddr,
> 2368                                         oiph->daddr,
> 2369                                         (skb->len - skb_transport_offset(skb)),
> 2370                                         IPPROTO_UDP, 0);
> 
> if compiler reports that oudph and oiph can be unitialized here,
> it's not enough just to set them to NULL.
> 
> Do we need probably to check that variables was initialized before access here?
> i.e. add  oudph && oiph into condition?

Sorry, I should not have mentioned my patch when it wasn't meant as
a serious submission. The patch I sent did not have a proper changelog
on it so it failed to explain it.

The reason why my patch works correctly is that the check on "l4_tunnel
== I40E_TXD_CTX_UDP_TUNNELING" means we can only get here if the
two variables have been initialized, and gcc fails to see this.

Jeff mentioned that he already had a patch for this, so I did not follow
up with a real patch.

	Arnd
