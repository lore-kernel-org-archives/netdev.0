From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rfs: add hash collision detection
Date: Sun, 08 Feb 2015 16:54:27 -0800 (PST)
Message-ID: <20150208.165427.953190098322716725.davem@davemloft.net>
References: <1423256341.31870.160.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, ycai@google.com,
	willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758588AbbBIAy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 19:54:28 -0500
In-Reply-To: <1423256341.31870.160.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Feb 2015 12:59:01 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Receive Flow Steering is a nice solution but suffers from
> hash collisions when a mix of connected and unconnected traffic
> is received on the host, when flow hash table is populated.
> 
> Also, clearing flow in inet_release() makes RFS not very good
> for short lived flows, as many packets can follow close().
> (FIN , ACK packets, ...)
> 
> This patch extends the information stored into global hash table
> to not only include cpu number, but upper part of the hash value.
> 
> I use a 32bit value, and dynamically split it in two parts.
> 
> For host with less than 64 possible cpus, this gives 6 bits for the
> cpu number, and 26 (32-6) bits for the upper part of the hash.
> 
> Since hash bucket selection use low order bits of the hash, we have
> a full hash match, if /proc/sys/net/core/rps_sock_flow_entries is big
> enough.
> 
> If the hash found in flow table does not match, we fallback to RPS (if
> it is enabled for the rxqueue).
> 
> This means that a packet for an non connected flow can avoid the
> IPI through a unrelated/victim CPU.
> 
> This also means we no longer have to clear the table at socket
> close time, and this helps short lived flows performance.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
