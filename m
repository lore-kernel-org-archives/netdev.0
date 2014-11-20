From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Remove some spurious dropped packet
 profile hits from the passive connection accept path
Date: Thu, 20 Nov 2014 12:47:03 -0800
Message-ID: <1416516423.8629.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141120185829.986CB290095D@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Rick Jones <raj@tardy.usa.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:43741 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758000AbaKTUrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 15:47:05 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so3590825iec.22
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 12:47:05 -0800 (PST)
In-Reply-To: <20141120185829.986CB290095D@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-20 at 10:58 -0800, Rick Jones wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> When a system is the passive accepter of many connections, for example
> when the target of a netperf TCP_CC or TCP_CRR test, or as say a web
> server, the discard of the skb containing the TCP SYN being processed
> for the LISTEN endpoint should be a consume_skb() rather than a kfree_skb()
> to avoid cluttering a dropped packet profile.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> ---

So what happens if we really drop the packet ?

TCP stack at this point owns the packet, it is possible to mark a bit in
it to either call consume_skb() or kfree_skb()

I attempted this once but gave up because it was a quite intrusive
patch...
