From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_packet: Add Queue mapping mode to af_packet fanout
 operation
Date: Wed, 22 Jan 2014 17:08:12 -0800
Message-ID: <1390439292.27806.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390424504-18543-1-git-send-email-nhorman@tuxdriver.com>
	 <52E03F80.8020803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:46999 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398AbaAWBIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 20:08:15 -0500
Received: by mail-yh0-f47.google.com with SMTP id c41so474998yho.6
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 17:08:15 -0800 (PST)
In-Reply-To: <52E03F80.8020803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-22 at 23:00 +0100, Daniel Borkmann wrote:
> On 01/22/2014 10:01 PM, Neil Horman wrote:
> > This patch adds a queue mapping mode to the fanout operation of af_packet
> > sockets.  This allows user space af_packet users to better filter on flows
> > ingressing and egressing via a specific hardware queue, and avoids the potential
> 
> Maybe I'm missing something, but I currently cannot find where this is
> being filled out for ingress path? Egress, ok, this gets filled out
> somewhere in protocol layers or elsewhere and is being locally pushed
> back through dev_queue_xmit_nit(), but I think main use case is ingress
> through packet fanout. In driver layer I can find skb->rxhash filled out
> which would then be PACKET_FANOUT_HASH.
> (Otherwise patch looks good.)


Check for various multiqueue drivers calling skb_record_rx_queue()
