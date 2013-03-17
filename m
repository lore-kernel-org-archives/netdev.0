From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net_sched: don't do precise pkt_len
 computation for untrusted packets
Date: Sun, 17 Mar 2013 12:10:26 -0400 (EDT)
Message-ID: <20130317.121026.733329595817911776.davem@davemloft.net>
References: <1363333305-54398-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, edumazet@google.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923Ab3CQQK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:10:27 -0400
In-Reply-To: <1363333305-54398-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 15 Mar 2013 15:41:44 +0800

> Commit 1def9238d4aa2 (net_sched: more precise pkt_len computation) tries to do
> precise packet len computation for GSO packets, but it does not check whether
> the packets were from untrusted source. This is wrong since: we haven't done
> header check before so both gso_segs and headers may not be correct. So this
> patch just bypass the precise pkt_len computation for packet from untrusted
> source (SKB_GSO_DODGY).
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I do not think this is appropriate or even necessary.

All the user can do by reporting an incorrect header size or GSO segs
is hurt himself, by making his traffic take more packet scheduler
quota.

When we do precise accounting, it increases, never decreases, the
amount that a packet "costs" as far as the packet scheduler is
concerned.
