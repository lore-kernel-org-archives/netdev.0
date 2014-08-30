From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] net: Checksum offload changes - Part VI
Date: Fri, 29 Aug 2014 20:41:38 -0700 (PDT)
Message-ID: <20140829.204138.372203125997855131.davem@davemloft.net>
References: <alpine.DEB.2.02.1408272114490.505@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbaH3Dlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:41:39 -0400
In-Reply-To: <alpine.DEB.2.02.1408272114490.505@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 27 Aug 2014 21:26:27 -0700 (PDT)

> I am working on overhauling RX checksum offload. Goals of this effort
> are:
> 
> - Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
> - Preserve CHECKSUM_COMPLETE through encapsulation layers
> - Don't do skb_checksum more than once per packet
> - Unify GRO and non-GRO csum verification as much as possible
> - Unify the checksum functions (checksum_init)
> - Simplify code
> 
> What is in this sixth patch set:
> 
> - Clarify the specific requirements of devices returning
>   CHECKSUM_UNNECESSARY (comments in skbuff.h).
> - Add csum_level field to skbuff. This is used to express how
>   many checksums are covered by CHECKSUM_UNNECESSARY (stores n - 1).
> - Change __skb_checksum_validate_needed to "consume" each checksum
>   as indicated by csum_level as layers of the the packet are parsed.
> - Remove skb_pop_rcv_encapsulation, no longer needed in the new
>   csum_level model.
> - Allow GRO path to "consume" checksums provided in CHECKSUM_UNNECESSARY
>   and to report new verfied checksums for use in normal path fallback.
> - Add proper support to SCTP to accept CHECKSUM_UNNECESSARY to validate
>   header CRC.
> - Modify drivers to set skb->csum_level instead of setting
>   skb->encapsulation to indicate validation of an encapsulated
>   checksum on receive.
> 
> v2:
> 
> Allocate a new 16 bits for flags in skbuff.

Series applied, thanks Tom.
