From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/tipc: initialize security state for new connection
 socket
Date: Wed, 08 Jul 2015 16:08:55 -0700 (PDT)
Message-ID: <20150708.160855.1027366470220223329.davem@davemloft.net>
References: <1436276625-3325-1-git-send-email-sds@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	paul@paul-moore.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbbGHXI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:08:56 -0400
In-Reply-To: <1436276625-3325-1-git-send-email-sds@tycho.nsa.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Smalley <sds@tycho.nsa.gov>
Date: Tue,  7 Jul 2015 09:43:45 -0400

> Calling connect() with an AF_TIPC socket would trigger a series
> of error messages from SELinux along the lines of:
> SELinux: Invalid class 0
> type=AVC msg=audit(1434126658.487:34500): avc:  denied  { <unprintable> }
>   for pid=292 comm="kworker/u16:5" scontext=system_u:system_r:kernel_t:s0
>   tcontext=system_u:object_r:unlabeled_t:s0 tclass=<unprintable>
>   permissive=0
> 
> This was due to a failure to initialize the security state of the new
> connection sock by the tipc code, leaving it with junk in the security
> class field and an unlabeled secid.  Add a call to security_sk_clone()
> to inherit the security state from the parent socket.
> 
> Reported-by: Tim Shearer <tim.shearer@overturenetworks.com>
> Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
> Acked-by: Paul Moore <paul@paul-moore.com>

Applied and queued up for -stable, thanks.
