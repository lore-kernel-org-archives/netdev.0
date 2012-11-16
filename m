From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 net-next] sctp: Add support to per-association
 statistics via a new SCTP_GET_ASSOC_STATS call
Date: Fri, 16 Nov 2012 11:39:22 -0500
Message-ID: <20121116163922.GA9722@hmsreliant.think-freely.org>
References: <1352991680-12289-1-git-send-email-michele@acksyn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34929 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739Ab2KPQjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 11:39:35 -0500
Content-Disposition: inline
In-Reply-To: <1352991680-12289-1-git-send-email-michele@acksyn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 15, 2012 at 04:01:20PM +0100, Michele Baldessari wrote:
> The current SCTP stack is lacking a mechanism to have per association
> statistics. This is an implementation modeled after OpenSolaris'
> SCTP_GET_ASSOC_STATS.
> 
> Userspace part will follow on lksctp if/when there is a general ACK on
> this.
> 
> V2)
>   - Implement partial retrieval of stat struct to cope for future expansion
>   - Kill the rtxpackets counter as it cannot be precise anyway
>   - Rename outseqtsns to outofseqtsns to make it clearer that these are out
>     of sequence unexpected TSNs
>   - Move asoc->ipackets++ under a lock to avoid potential miscounts
>   - Fold asoc->opackets++ into the already existing asoc check
>   - Kill unneeded (q->asoc) test when increasing rtxchunks
>   - Do not count octrlchunks if sending failed (SCTP_XMIT_OK != 0)
>   - Don't count SHUTDOWNs as SACKs
>   - Move SCTP_GET_ASSOC_STATS to the private space API
>   - Adjust the len check in sctp_getsockopt_assoc_stats() to allow for
>     future struct growth
>   - Move association statistics in their own struct
>   - Update idupchunks when we send a SACK with dup TSNs
>   - return min_rto in max_rto when RTO has not changed. Also return the
>     transport when max_rto last changed.
> 
> Signed-off: Michele Baldessari <michele@acksyn.org>
> Acked-by: Thomas Graf <tgraf@suug.ch>

Yes, I think this is good, I still don't like the idea of having to do these via
an ioctl, but I suppose it fits well enough.
Neil

Acked-by: Neil Horman <nhorman@tuxdriver.com>
