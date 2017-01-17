From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fq_codel and skb->hash
Date: Mon, 16 Jan 2017 17:44:49 -0800
Message-ID: <1484617489.13165.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <f9913fca-da16-8620-d237-d7d8d09cced2@cradlepoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Andrew Collins <acollins@cradlepoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35046 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdAQBw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 20:52:56 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so6574670pge.2
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 17:52:56 -0800 (PST)
In-Reply-To: <f9913fca-da16-8620-d237-d7d8d09cced2@cradlepoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-16 at 17:04 -0700, Andrew Collins wrote:
> The fq_codel packet scheduler always regenerates the skb flow hash.  Is there any reason
> to do this other than the recent hash perturbation additions?
> 
> I ask because I have a case where an incoming set of TCP flows is encapsulated in a
> single ipsec tunnel, which is then classified on egress into a single flow by fq_codel
> resulting in poor behavior.
> 
> Reusing the skb hash set in receive results in much better behavior, as the value is
> determined pre-encapsulation and flows end up being distributed more naturally across
> codel queues.



> 
> Is opportunistically using the pre-existing skb hash (if available) problematic?

I guess this would be fine.

We never exported the 'perturbation' or allowed to change/set it.

The only 'risk' would be having a buggy device setting a wrong L4
skb->hash, or buggy protocol messing with skb->hash for a given flow.

>   Is there a better way to manage flow separation in routed+encapsulated traffic?

Encapsulated traffic is fine, since flow dissector skips encap header(s)
up to the L4 header.

Problem is about encrypted traffic, since presumably this L4 header is
opaque for flow dissector ;)
