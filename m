From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] flow_dissector: remove
 __flow_hash_consistentify
Date: Wed, 29 Jul 2015 23:19:34 +0200
Message-ID: <1438204774.20182.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438202943-937619-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36352 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbbG2VTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 17:19:37 -0400
Received: by wicgb10 with SMTP id gb10so217917338wic.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 14:19:36 -0700 (PDT)
In-Reply-To: <1438202943-937619-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-29 at 13:49 -0700, Tom Herbert wrote:
> The intent of this function was to produce a consistent hash for both
> directions of a flow. However, since we added more inputs to the flow
> hashing (IPv6 flow labels for instance) in a lot of cases we won't get
> the same hash computed for each direction anyway. Also, there is no
> defined correlation between the hashes computed in each direction of a
> flow.
> 
> This patch removes the function since it is not providing significant
> value and is expensive to be called for every packet. If there are
> ever users of the flow_hash_from_keys that did require consistency
> they can swap addresses and ports as needed in the flow_keys before
> calling flow_hash_from_keys.

Have you tested this change with conntracking and RPS enabled ?

This was whole point from commit b249dcb82d327e41

I guess difference is even bigger today after removal of central
conntracking lock.
