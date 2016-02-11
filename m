From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/10] Add GSO support for outer checksum w/
 inner checksum offloads
Date: Thu, 11 Feb 2016 09:32:06 -0500 (EST)
Message-ID: <20160211.093206.798004360524314137.davem@davemloft.net>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	ecree@solarflare.com, tom@herbertland.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbcBKOcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 09:32:13 -0500
In-Reply-To: <20160205232109.18529.99816.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Fri, 05 Feb 2016 15:27:25 -0800

> This patch series updates the existing segmentation offload code for
> tunnels to make better use of existing and updated GSO checksum
> computation.  This is done primarily through two mechanisms.  First we
> maintain a separate checksum in the GSO context block of the sk_buff.  This
> allows us to maintain two checksum values, one offloaded with values stored
> in csum_start and csum_offset, and one computed and tracked in
> SKB_GSO_CB(skb)->csum.  By maintaining these two values we are able to take
> advantage of the same sort of math used in local checksum offload so that
> we can provide both inner and outer checksums with minimal overhead.
> 
> Below is the performance for a netperf session between an ixgbe PF and VF
> on the same host but in different namespaces.  As can be seen a significant
> gain in performance can be had from allowing the use of Tx checksum offload
> on the inner headers while performing a software offload on the outer
> header computation:
> 
>  Recv   Send   Send                       Utilization  Service Demand
>  Socket Socket Message Elapsed            Send  Recv   Send  Recv
>  Size   Size   Size    Time    Throughput local remote local remote
>  bytes  bytes  bytes   secs.   10^6bits/s % S   % U    us/KB us/KB
> 
> Before:
>  87380  16384  16384   10.00   12844.38   9.30  -1.00  0.712 -1.00
> After:
>  87380  16384  16384   10.00   13216.63   6.78  -1.00  0.504 -1.000
> 
> Changes from v1:
> * Dropped use of CHECKSUM_UNNECESSARY for remote checksum offload
> * Left encap_hdr_csum as it will likely be needed in future for SCTP GSO
> * Broke the changes out over many more patches
> * Updated GRE segmentation to more closely match UDP tunnel segmentation

Series applied, thanks Alex.
