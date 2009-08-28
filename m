From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 16:00:24 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908281556480.17784@gentwo.org>
References: <alpine.DEB.1.10.0908280948320.3747@gentwo.org> <4A97F2B4.7030900@gmail.com> <alpine.DEB.1.10.0908281211150.7317@gentwo.org> <20090828.122658.188210079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:59269 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752263AbZH1UJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 16:09:44 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4B34082C7DE
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 16:10:58 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BaAtFIth60Dv for <netdev@vger.kernel.org>;
	Fri, 28 Aug 2009 16:10:58 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A94F582C7E4
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 16:10:53 -0400 (EDT)
In-Reply-To: <20090828.122658.188210079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2009, David Miller wrote:

> I'm not accepting changes like the patch you propose here, it's not
> the correct thing to do.
>
> The device never saw the packet, it never dropped it.
>
> The qdisc saw it, the qdisc dropped it, and therefore that's where we
> account for it.

udp send currently drops packets without any error message and without
incrementing any counters.

That occurs only if the socket option IP_RECVERR is not set.

If you set IP_RECVERR then statistics are kept about dropped packets and
they are displayed as drops at the IP and UDP layer.

Are you saying that this behavior is okay? It is desired behavior that a
socket option changes the way how global network counters are handled?


