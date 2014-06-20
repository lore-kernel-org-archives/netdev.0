From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: check proc_dointvec result in
 proc_sctp_do_auth
Date: Thu, 19 Jun 2014 21:31:37 -0700 (PDT)
Message-ID: <20140619.213137.2272589325097681936.davem@davemloft.net>
References: <1403127991-18114-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932269AbaFTEbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 00:31:39 -0400
In-Reply-To: <1403127991-18114-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 18 Jun 2014 23:46:31 +0200

> When writing to the sysctl field net.sctp.auth_enable, it can well
> be that the user buffer we handed over to proc_dointvec() via
> proc_sctp_do_auth() handler contains something other than integers.
> 
> In that case, we would set an uninitialized 4-byte value from the
> stack to net->sctp.auth_enable that can be leaked back when reading
> the sysctl variable, and it can unintentionally turn auth_enable
> on/off based on the stack content since auth_enable is interpreted
> as a boolean.
> 
> Fix it up by making sure proc_dointvec() returned sucessfully.
> 
> Fixes: b14878ccb7fa ("net: sctp: cache auth_enable per endpoint")
> Reported-by: Florian Westphal <fwestpha@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
