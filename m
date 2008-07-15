From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] ethtool: Expand ethtool_cmd.speed to 32 bits
Date: Tue, 15 Jul 2008 14:53:16 -0700
Message-ID: <487D1C4C.9080103@hp.com>
References: <20080715091841.GA6553@potty.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:37859 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbYGOVxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 17:53:20 -0400
In-Reply-To: <20080715091841.GA6553@potty.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandon Philips wrote:
> Introduce the speed_hi field to ethtool_cmd, using the reserved space,
> to expand the speed field to 2^32 Megabits/second.
> 
> Making this field expansion now gives us plenty of time to fix up the
> user-space pieces that use SIOCETHTOOL before hardware faster than 64
> Gb/s is available.
> 
> Signed-off-by: Brandon Philips <bphilips@suse.de>
> 
> ---
>  include/linux/ethtool.h |   17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/include/linux/ethtool.h
> ===================================================================
> --- linux-2.6.orig/include/linux/ethtool.h
> +++ linux-2.6/include/linux/ethtool.h
> @@ -27,9 +27,24 @@ struct ethtool_cmd {
>  	__u8	autoneg;	/* Enable or disable autonegotiation */
>  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
>  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> -	__u32	reserved[4];
> +	__u16	speed_hi;
> +	__u16	reserved2;
> +	__u32	reserved[3];
>  };

I certainly agree with the concept of preparing for faster NICs.  Are 
bits in that structure sufficiently precious to go the split route, or 
would it be cleaner to just grab a contiguous 32 bits from the structure?

rick jones
