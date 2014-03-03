From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2 net] macvlan: Add support for 'always_on' offload features
Date: Mon, 03 Mar 2014 15:49:40 -0800
Message-ID: <53151514.4080906@candelatech.com>
References: <1393878833-17667-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53342 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182AbaCCXtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 18:49:53 -0500
In-Reply-To: <1393878833-17667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2014 12:33 PM, Vlad Yasevich wrote:
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

If users specifically disable the offload features on the macvlan using ethtool,
will they be turned off?  If not, then I think that logic should
be kept somehow?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
