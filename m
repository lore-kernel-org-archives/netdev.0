From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v5 net-next] MPLS: Use mpls_features to activate software
 MPLS GSO segmentation
Date: Wed, 4 Jun 2014 11:13:36 +0100
Message-ID: <20140604101336.GE17695@casper.infradead.org>
References: <1401839597-8961-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	YAMAMOTO Takashi <yamamoto@valinux.co.jp>, dev@openvswitch.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45912 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbaFDKNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 06:13:40 -0400
Content-Disposition: inline
In-Reply-To: <1401839597-8961-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/14 at 08:53am, Simon Horman wrote:
> If an MPLS packet requires segmentation then use mpls_features
> to determine if the software implementation should be used.
> 
> As no driver advertises MPLS GSO segmentation this will always be
> the case.
> 
> I had not noticed that this was necessary before as software MPLS GSO
> segmentation was already being used in my test environment. I believe that
> the reason for that is the skbs in question always had fragments and the
> driver I used does not advertise NETIF_F_FRAGLIST (which seems to be the
> case for most drivers). Thus software segmentation was activated by
> skb_gso_ok().
> 
> This introduces the overhead of an extra call to skb_network_protocol()
> in the case where where CONFIG_NET_MPLS_GSO is set and
> skb->ip_summed == CHECKSUM_NONE.
> 
> Thanks to Jesse Gross for prompting me to investigate this.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> Acked-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>

LGTM

Acked-by: Thomas Graf <tgraf@suug.ch>
