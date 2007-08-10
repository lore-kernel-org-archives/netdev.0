From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [NET] ethtool: Add LRO support
Date: Fri, 10 Aug 2007 04:42:44 -0400
Message-ID: <46BC2504.9010400@garzik.org>
References: <20070809164117.9907.23351.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ossthema@de.ibm.com
To: Auke Kok <auke-jan.h.kok@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53902 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758817AbXHJIms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 04:42:48 -0400
In-Reply-To: <20070809164117.9907.23351.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  include/linux/ethtool.h   |    8 +++++++
>  include/linux/netdevice.h |    1 +
>  net/core/ethtool.c        |   53 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 62 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 23ccea8..a97248e 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -272,6 +272,8 @@ u32 ethtool_op_get_tso(struct net_device *dev);
>  int ethtool_op_set_tso(struct net_device *dev, u32 data);
>  u32 ethtool_op_get_ufo(struct net_device *dev);
>  int ethtool_op_set_ufo(struct net_device *dev, u32 data);
> +u32 ethtool_op_get_lro(struct net_device *dev);
> +int ethtool_op_set_lro(struct net_device *dev, u32 data);

I'm thinking we don't need to keep adding two function pointers for each 
boolean choice.

I propose adding two operations:

get-flags:	return 32-bit (even on 64-bit platforms) flags bitmap
set-flags:	set 32-bit flags bitmap

The 32 bits shall be divided as follows:

bits 0-23:	ETHTOOL_FLAG_xxx defined in linux/ethtool.h
bits 24-31:	driver-specific boolean flags

The driver-specific flags are first enumerated by userland via an 
ETHTOOL_GSTRINGS call, using new string set ETH_SS_FLAGS.  The first 
string returned names the first driver-private flag (bit 24).  This also 
indicates that driver-private bit 24 is a valid flag for this driver and 
network interface.

The overall goal is to replace get-LRO/set-LRO operations with the 
setting/clearing of ETH_FLAG_LRO, and as well, provide a more-scalable 
ethtool interface.

I'll code this up, along with the associated generic helpers 
(net/core/ethtool.c), if there are no objections.

	Jeff



