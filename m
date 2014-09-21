From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] net: Eliminate gso_send_check
Date: Sat, 20 Sep 2014 18:04:00 -0700
Message-ID: <1411261440.26859.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411249950-6795-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:44807 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaIUBEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 21:04:01 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so411183pde.36
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:04:01 -0700 (PDT)
In-Reply-To: <1411249950-6795-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 14:52 -0700, Tom Herbert wrote:
> gso_send_check presents a lot of complexity for what it is being used
> for. It seems that there are only two cases where it might be effective:
> TCP and UFO paths. In these cases, the gso_send_check function
> initializes the TCP or UDP checksum respectively to the pseudo header
> checksum so that the checksum computation is appropriately offloaded or
> computed in the gso_segment functions. The gso_send_check functions
> are only called from dev.c in skb_mac_gso_segment when ip_summed !=
> CHECKSUM_PARTIAL (which seems very unlikely in TCP case). We can move
> the logic of this into the respective gso_segment functions where the
> checksum is initialized if ip_summed != CHECKSUM_PARTIAL.
> 
> With the above cases handled, gso_send_check is no longer needed, so
> we can remove all uses of it and the fields in the offload callbacks.
> With this change, ip_summed in the skb should be preserved though all
> the layers of gso_segment calls.
> 
> In follow-on patches, we may be able to remove the check setup code in
> tcp_gso_segment if we can guarantee that ip_summed will always be
> CHECKSUM_PARTIAL (verify all paths and probably add an assert in
> tcp_gro_segment).
> 
> Tested these patches by:
>   - netperf TCP_STREAM test with GSO enabled
>   - Forced ip_summed != CHECKSUM_PARTIAL with above
>   - Ran UDP_RR with 10000 request size over GRE tunnel. This exercised
>     UFO path.
> 
> Tom Herbert (3):
>   tcp: move logic out of tcp_v[64]_gso_send_check
>   udp: move logic out of udp[46]_ufo_send_check
>   net: Remove gso_send_check as an offload callback

Very very nice !

Acked-by: Eric Dumazet <edumazet@google.com>
