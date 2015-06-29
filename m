From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] sctp: Fix race between OOTB responce and route
 removal
Date: Mon, 29 Jun 2015 09:29:02 -0700 (PDT)
Message-ID: <20150629.092902.445099737868203960.davem@davemloft.net>
References: <5591049F.3040108@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com,
	marcelo.leitner@gmail.com, vyasevich@gmail.com
To: alexander.sverdlin@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43886 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbbF2Q3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 12:29:03 -0400
In-Reply-To: <5591049F.3040108@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Date: Mon, 29 Jun 2015 10:41:03 +0200

> There is NULL pointer dereference possible during statistics update if the route
> used for OOTB responce is removed at unfortunate time. If the route exists when
> we receive OOTB packet and we finally jump into sctp_packet_transmit() to send
> ABORT, but in the meantime route is removed under our feet, we take "no_route"
> path and try to update stats with IP_INC_STATS(sock_net(asoc->base.sk), ...).
> 
> But sctp_ootb_pkt_new() used to prepare responce packet doesn't call
> sctp_transport_set_owner() and therefore there is no asoc associated with this
> packet. Probably temporary asoc just for OOTB responces is overkill, so just
> introduce a check like in all other places in sctp_packet_transmit(), where
> "asoc" is dereferenced.
> 
> To reproduce this, one needs to
> 0. ensure that sctp module is loaded (otherwise ABORT is not generated)
> 1. remove default route on the machine
> 2. while true; do
>      ip route del [interface-specific route]
>      ip route add [interface-specific route]
>    done
> 3. send enough OOTB packets (i.e. HB REQs) from another host to trigger ABORT
>    responce
> 
> On x86_64 the crash looks like this:
 ...
> Signed-off-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied and queued up for -stable, thanks.
