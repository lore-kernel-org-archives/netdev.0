From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: find correct route for socket which is not bound
 to a device
Date: Thu, 17 Sep 2015 21:20:00 -0700 (PDT)
Message-ID: <20150917.212000.1163539662854684723.davem@davemloft.net>
References: <1442385255-27014-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wen.gang.wang@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbbIREUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 00:20:01 -0400
In-Reply-To: <1442385255-27014-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wengang Wang <wen.gang.wang@oracle.com>
Date: Wed, 16 Sep 2015 14:34:15 +0800

> For multi-cast, we should find valid route(thus get the meaniful pmtu) for
> the package on the socket which is not bound to a device(sk_bound_dev_if
> being 0) too.

Your patch breaks exactly the situation explained in full detail
in the huge comment about the first change you are making:

			/* Special hack: user can direct multicasts
			   and limited broadcast via necessary interface
			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
			   This hack is not just for fun, it allows
			   vic,vat and friends to work.
			   They bind socket to loopback, set ttl to zero
			   and expect that it will work.
			   From the viewpoint of routing cache they are broken,
			   because we are not allowed to build multicast path
			   with loopback source addr (look, routing cache
			   cannot know, that ttl is zero, so that packet
			   will not leave this host and route is valid).
			   Luckily, this hack is good workaround.
			 */

That situation will now fail after your patch.

So I cannot apply this patch, sorry.

I know what you want, you want to end up with a cached route that
will track the PMTU.  But this hack will break other things at
the same time so is not acceptable.
