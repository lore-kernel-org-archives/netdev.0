From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] TCP:  Support configurable delayed-ack parameters.
Date: Mon, 18 Jun 2012 18:27:16 -0700
Message-ID: <20120618182716.5f8fb72f@nehalam.linuxnetplumber.net>
References: <1340067163-29329-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55651 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865Ab2FSB1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 21:27:21 -0400
In-Reply-To: <1340067163-29329-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Jun 2012 17:52:43 -0700
greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> RFC2581 ($4.2) specifies when an ACK should be generated as follows:
> 
> " .. an ACK SHOULD be generated for at least every second
>   full-sized segment, and MUST be generated within 500 ms
>   of the arrival of the first unacknowledged packet.
> "
> 
> We export the number of segments and the timeout limits
> specified above, so that a user can tune them according
> to their needs.
> 
> Specifically:
> 	* /proc/sys/net/ipv4/tcp_default_delack_segs, represents
> 	the threshold for the number of segments.
> 	* /proc/sys/net/ipv4/tcp_default_delack_min, specifies
> 	the minimum timeout value
> 	* /proc/sys/net/ipv4/tcp_default_delack_max, specifies
> 	the maximum timeout value.
> 
> In addition, new TCP socket options are added to allow
> per-socket configuration:
> 
> TCP_DELACK_SEGS
> TCP_DELACK_MIN
> TCP_DELACK_MAX
> 
> In order to keep a multiply out of the hot path, the segs * mss
> computation is recalculated and cached whenever segs or mss changes.
> 
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
> Signed-off-by: Ben Greear <greearb@candelatech.com>

What is the justification (other than standard) for making this
tunable. Why would you want to do this? Why shouldn't the stack be adjusting
it for you (based on other heuristics)? Or is this just for testing interoperation
with TCP stacks that have wonky ACK policies. There are already too many TCP tunable
parameters for general usage.
