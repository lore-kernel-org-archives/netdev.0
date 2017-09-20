From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as
 standalone
Date: Wed, 20 Sep 2017 17:27:52 +0200
Message-ID: <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-10-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:59151 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751697AbdITPhK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 11:37:10 -0400
In-Reply-To: <20170919003904.5124-10-tom@quantonium.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/09/17 02:38, Tom Herbert wrote:
> Add new configuration of GTP interfaces that allow specifying a port to
> listen on (as opposed to having to get sockets from a userspace control
> plane). This allows GTP interfaces to be configured and the data path
> tested without requiring a GTP-C daemon.

This would imply that you can have multiple independent GTP sockets on 
the same IP address.That is not permitted by the GTP specifications. 
3GPP TS 29.281, section 4.3 states clearly that there is "only" one GTP 
entity per IP address.A PDP context is defined by the destination IP and 
the TEID. The destination port is not part of the identity of a PDP context.

Even the source IP and source port are not part of the tunnel identity. 
This makes is possible to send traffic from a new SGSN/SGW during 
handover before the control protocol has announced the handover.

At this point the usual response is: THAT IS NOT SAFE. Yes, GTP has been 
designed for cooperative networks only and should not be used on 
hostile/unsecured networks.

On the sending side, using multiple ports is permitted as long as the 
default GTP port is always able to receive incoming messages.

Andreas

[...]
