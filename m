From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: Add socket early demux support
Date: Tue, 26 Jun 2012 14:34:01 -0700 (PDT)
Message-ID: <20120626.143401.445148198931339546.davem@davemloft.net>
References: <1340739826-3363-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	eric.dumazet@gmail.com, alexander.h.duyck@intel.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab2FZVeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 17:34:04 -0400
In-Reply-To: <1340739826-3363-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You can't do this.

If the UDP socket has wildcards, that means the source address of the
route will not be validated.  This means we will start accepting
spoofed packets.  It also means the route you are caching is going
to be the wrong route since the keys are variable.

You can only do an early demux where all the keys are fully specified
and there are no wildcards.  That why for TCP we only early demux for
established sockets.
