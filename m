From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: Fix PMTU update.
Date: Sun, 13 Mar 2011 18:38:45 -0700 (PDT)
Message-ID: <20110313.183845.226774350.davem@davemloft.net>
References: <20110310150958.123c9f7f.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44997
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756737Ab1CNBiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 21:38:08 -0400
In-Reply-To: <20110310150958.123c9f7f.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Thu, 10 Mar 2011 15:09:58 +0900

> On current net-next-2.6, when Linux receives ICMP Type: 3, Code: 4
> (Destination unreachable (Fragmentation needed)), 
> 
>   icmp_unreach
>     -> ip_rt_frag_needed
>          (peer->pmtu_expires is set here)
>     -> tcp_v4_err
>          -> do_pmtu_discovery
>               -> ip_rt_update_pmtu
>                    (peer->pmtu_expires is already set,
>                     so check_peer_pmtu is skipped.)
>                    -> check_peer_pmtu
> 
> check_peer_pmtu is skipped and MTU is not updated.
> 
> To fix this, let check_peer_pmtu execute unconditionally.
> And some minor fixes
> 1) Avoid potential peer->pmtu_expires set to be zero.
> 2) In check_peer_pmtu, argument of time_before is reversed.
> 3) check_peer_pmtu expects peer->pmtu_orig is initialized as zero,
>    but not initialized.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

This looks great, thanks for fixing this bug.

Applied.
