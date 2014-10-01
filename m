From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next] udp: increment UDP_NO_PORTS when dropping unmatched
 multicasts
Date: Wed, 01 Oct 2014 12:59:18 -0400
Message-ID: <542C32E6.7080106@oracle.com>
References: <20141001151921.7131E29003A2@tardy> <542C23AA.6060505@oracle.com> <542C2CAB.2030501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27648 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbaJAQ7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 12:59:24 -0400
In-Reply-To: <542C2CAB.2030501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/01/2014 12:32 PM, Rick Jones wrote:

> 
> Do you think an "ignored" statistic would be appropriate then?

I guess I don't know what that means. If we didn't join the group, it
should be treated like anything we'd receive in promiscuous mode that
is not addressed to us. I'd assume interface stats are going up, but not
any protocol stats in that case. (already the case)

If we did join the group, it should be treated the way we would, say,
a broadcast UDP packet where we have no listener on that port.

It isn't clear to me that maintaining the stat is worth checking for
group membership, but we wouldn't want an admin to conclude there is
a problem or an error because we increment a stat when doing the
equivalent of hardware MAC address filtering, just because multicast
address filters are defined to be leaky.

						+-DLS
