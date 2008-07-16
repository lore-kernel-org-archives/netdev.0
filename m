From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH net-next] sctp: Prevent uninitialized memory access
Date: Wed, 16 Jul 2008 09:35:24 -0400
Message-ID: <487DF91C.9060906@hp.com>
References: <1215954556-31685-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:34829 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756038AbYGPNgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 09:36:52 -0400
In-Reply-To: <1215954556-31685-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal wrote:
> valgrind reports uninizialized memory accesses when running
> sctp inside the network simulation cradle simulator:
> 
>  Conditional jump or move depends on uninitialised value(s)
>     at 0x570E34A: sctp_assoc_sync_pmtu (associola.c:1324)
>     by 0x57427DA: sctp_packet_transmit (output.c:403)
>     by 0x5710EFF: sctp_outq_flush (outqueue.c:824)
>     by 0x5710B88: sctp_outq_uncork (outqueue.c:701)
>     by 0x5745262: sctp_cmd_interpreter (sm_sideeffect.c:1548)
>     by 0x57444B7: sctp_side_effects (sm_sideeffect.c:976)
>     by 0x5744460: sctp_do_sm (sm_sideeffect.c:945)
>     by 0x572157D: sctp_primitive_ASSOCIATE (primitive.c:94)
>     by 0x5725C04: __sctp_connect (socket.c:1094)
>     by 0x57297DC: sctp_connect (socket.c:3297)
> 
>  Conditional jump or move depends on uninitialised value(s)
>     at 0x575D3A5: mod_timer (timer.c:630)
>     by 0x5752B78: sctp_cmd_hb_timers_start (sm_sideeffect.c:555)
>     by 0x5754133: sctp_cmd_interpreter (sm_sideeffect.c:1448)
>     by 0x5753607: sctp_side_effects (sm_sideeffect.c:976)
>     by 0x57535B0: sctp_do_sm (sm_sideeffect.c:945)
>     by 0x571E9AE: sctp_endpoint_bh_rcv (endpointola.c:474)
>     by 0x573347F: sctp_inq_push (inqueue.c:104)
>     by 0x572EF93: sctp_rcv (input.c:256)
>     by 0x5689623: ip_local_deliver_finish (ip_input.c:230)
>     by 0x5689759: ip_local_deliver (ip_input.c:268)
>     by 0x5689CAC: ip_rcv_finish (dst.h:246)
> 
> #1 is due to "if (t->pmtu_pending)".
> 8a4794914f9cf2681235ec2311e189fe307c28c7 "[SCTP] Flag a pmtu change request"
> suggests it should be initialized to 0.
> 
> #2 is the heartbeat timer 'expires' value, which is uninizialised, but
> test by mod_timer().
> T3_rtx_timer seems to be affected by the same problem, so initialize it, too.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Thanks

Applied.

-vlad
