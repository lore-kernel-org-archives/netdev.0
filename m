From: David Miller <davem@davemloft.net>
Subject: Re: bind() should not return -EADDRINUSE
Date: Thu, 11 Dec 2014 14:23:55 -0500 (EST)
Message-ID: <20141211.142355.854082841833367081.davem@davemloft.net>
References: <5489EE2F.6030502@ubuntu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: psusi@ubuntu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758633AbaLKTX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:23:57 -0500
In-Reply-To: <5489EE2F.6030502@ubuntu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phillip Susi <psusi@ubuntu.com>
Date: Thu, 11 Dec 2014 14:19:11 -0500

> Attempting to establish a connection to a remote host using the same
> local port, but a different remote port as the previous connection (
> that is still in TIME_WAIT ) results in bind() returning -EADDRINUSE.
>  By changing the remote port, you avoid the conflict with the other
> connection that is in TIME_WAIT, but since the remote port is not
> known when bind() is called, it incorrectly returns -EADDRINUSE.  This
> check should not be done in bind(), but deferred until the remote port
> is known in the call to connect(), or listen().

Bind has to allocate and hold from everyone else on the system the
local port at bind() time, so we cannot defer this decision.
