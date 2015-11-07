From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: delay address promotion check until last request
 in message
Date: Sat, 07 Nov 2015 13:17:14 -0500 (EST)
Message-ID: <20151107.131714.232754521490501858.davem@davemloft.net>
References: <1446839495-32719-1-git-send-email-nhorman@tuxdriver.com>
	<alpine.LFD.2.11.1511062352270.1904@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbbKGSRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 13:17:17 -0500
In-Reply-To: <alpine.LFD.2.11.1511062352270.1904@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 7 Nov 2015 01:49:25 +0200 (EET)

> On Fri, 6 Nov 2015, Neil Horman wrote:
> 
>> The solution is to recognize that its pointless to promote an address to be a
>> new primary, if there is a possibility that it will just be removed in the near
>> future.  As such this patch peeks ahead to the next request in the provided
>> netlink message, and, if it is both valid and a RTM_DELADDR request, skips the
>> promotion check.  This eliminates the need to iterate through a nested for loop
> 
> 	flush can provide many parameters. As there is no
> any kind of indication in the netlink message that all addresses
> are removed, we can not avoid the promotion.
> 
>> +	 * Only check for address promotion when this is the last request
>> +	 * in this netlink transaction.  It allows this operation to complete
>> +	 * in O(n) time rather than O(n^2)
> 
> 	It is not correct to assume that one promotion per
> transaction is enough. The promotion happens in every subnet,
> it was not once per device.

Agreed, this optimization is invalid.
