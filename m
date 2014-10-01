From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next] udp: increment UDP_NO_PORTS when dropping unmatched
 multicasts
Date: Wed, 01 Oct 2014 11:54:18 -0400
Message-ID: <542C23AA.6060505@oracle.com>
References: <20141001151921.7131E29003A2@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Rick Jones <raj@tardy.usa.hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44610 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaJAPzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 11:55:33 -0400
In-Reply-To: <20141001151921.7131E29003A2@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this would have the unpleasant side-effect of incrementing a drop
stat when we have not joined a multicast group that has UDP traffic, but the
interface is in promiscuous mode. Also, false positives for the multicast
address filter.

Multicast address filters are not perfect matches, so it is "normal" to receive
multicasts and broadcasts that are not addressed to our host. I'm not sure those
should count as "noports" any more than traffic addressed to someone else's IP
address if we're in promiscuous mode should.

In the multicast case, it would really only make sense if we have actually joined
the group it's addressed to.

						+-DLS
