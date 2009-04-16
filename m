From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Thu, 16 Apr 2009 08:09:56 -0400
Message-ID: <200904160809.56228.alexandre.sidorenko@hp.com>
References: <20090415195022.GA3322@ami.dom.local> <200904151610.43980.alexandre.sidorenko@hp.com> <20090416.031034.41207844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "jarkao2@gmail.com" <jarkao2@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:5387 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbZDPMJ5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 08:09:57 -0400
In-Reply-To: <20090416.031034.41207844.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On April 16, 2009 06:10:34 am David Miller wrote:
> Since IFB completely bypasses netif_rx() and netif_receive_skb() I
> think it should unconditionally set skb->tstamp.tv64 to zero and
> invoke net_timestamp()

>From ifb.c (2.6.29):

 109                if (from & AT_EGRESS) {
 110                        dp->st_rx_frm_egr++;
 111                        dev_queue_xmit(skb);
 112                } else if (from & AT_INGRESS) {
 113                        dp->st_rx_frm_ing++;
 114                        skb_pull(skb, skb->dev->hard_header_len);
 115                        netif_rx(skb);
 116                }

Adding skb->tstamp.tv64 = 0 between lines 114 and 115 made 'ping' report the 
delay as expected (tested on 2.6.28)

Alex


-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: asid@hp.com
WTEC Linux			Hewlett-Packard (Canada)
------------------------------------------------------------------
