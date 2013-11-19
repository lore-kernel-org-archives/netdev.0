From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix copying sk_v6_rcv_saddr in
 sctp_v6_create_accept_sk
Date: Tue, 19 Nov 2013 16:10:49 -0500 (EST)
Message-ID: <20131119.161049.40606385929854732.davem@davemloft.net>
References: <1384858284-2246-1-git-send-email-dborkman@redhat.com>
	<528B85E2.5080403@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, wangweidong1@huawei.com,
	eric.dumazet@gmail.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab3KSVKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 16:10:51 -0500
In-Reply-To: <528B85E2.5080403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Tue, 19 Nov 2013 10:38:10 -0500

> This fixes the issue for the accept() case, but the bug is still there
> in the peeloff case.
> 
> I think you should make sctp_copy_sock() use sock_copy() for now.  It
> looks like it will catch all the cases.
> 
> We can then look at possibly getting rid of sctp_copy_sock() for net-next.

Agreed, it looks like a lot of hair exists because sctp tries to use
custom code to copy sockets.  Getting away from this will fix this
address problem as well as things like the pacing rate being wrong
as Eric Dumazet mentioned.
