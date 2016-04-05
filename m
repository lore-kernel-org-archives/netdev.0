From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Fix error handling for switch statement case in
 the function sctp_cmd_interprete
Date: Tue, 05 Apr 2016 19:29:10 -0400 (EDT)
Message-ID: <20160405.192910.1219063056390496976.davem@davemloft.net>
References: <1459892201-21397-1-git-send-email-bastienphilbert@gmail.com>
	<570433F0.6040506@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bastienphilbert@gmail.com, vyasevich@gmail.com,
	nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbcDEX3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 19:29:13 -0400
In-Reply-To: <570433F0.6040506@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 05 Apr 2016 23:53:52 +0200

> On 04/05/2016 11:36 PM, Bastien Philbert wrote:
>> This fixes error handling for the switch statement case
>> SCTP_CMD_SEND_PKT by making the error value of the call
>> to sctp_packet_transmit equal the variable error due to
>> this function being able to fail with a error code. In
> 
> What actual issue have you observed that you fix?
> 
>> addition allow the call to sctp_ootb_pkt_free afterwards
>> to free up the no longer in use sctp packet even if the
>> call to the function sctp_packet_transmit fails in order
>> to avoid a memory leak here for not freeing the sctp
> 
> Not sure how this relates to your code?

Bastien, I'm seeing a clear negative pattern with the bug fixes
you are submitting.

Just now you submitted the ICMP change which obviously was never
tested because it tried to take the RTNL mutex in atomic context,
and now this sctp thing.

If you don't start actually testing your changes and expalining
clearly what the problem actually is, how you discovered it,
and how you actually tested your patch, I will start completely
ignoring your patch submissions.
