From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] macvlan: Add support for 'always_on' offload
 features
Date: Mon, 03 Mar 2014 16:44:17 -0500 (EST)
Message-ID: <20140303.164417.1636190597062161229.davem@davemloft.net>
References: <1393878833-17667-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, borntraeger@de.ibm.com,
	jasowang@redhat.com, mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbaCCVoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 16:44:19 -0500
In-Reply-To: <1393878833-17667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon,  3 Mar 2014 15:33:53 -0500

> Macvlan currently inherits all of its features from the lower
> device.  When lower device disables offload support, this causes
> macvlan to disable offload support as well.  This causes
> performance regression when using macvlan/macvtap in bridge
> mode.
> 
> It can be easily demonstrated by creating 2 namespaces using
> macvlan in bridge mode and running netperf between them:
> 
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    20.00    1204.61
> 
> To restore the performance, we add software offload features
> to the list of "always_on" features for macvlan.  This way
> when a namespace or a guest using macvtap initially sends a
> packet, this packet will not be segmented at macvlan level.
> It will only be segmented when macvlan sends the packet
> to the lower device.
> 
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    20.00    5507.35
> 
> Fixes: 6acf54f1cf0a6747bac9fea26f34cfc5a9029523 (macvtap: Add support of packet capture on macvtap device.)
> Fixes: 797f87f83b60685ff8a13fa0572d2f10393c50d3 (macvlan: fix netdev feature propagation from lower device)
> CC: Florian Westphal <fw@strlen.de>
> CC: Christian Borntraeger <borntraeger@de.ibm.com>
> CC: Jason Wang <jasowang@redhat.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
