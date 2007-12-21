From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH] OOPS with NETLINK_FIB_LOOKUP netlink socket
Date: Fri, 21 Dec 2007 12:39:36 +0300
Message-ID: <476B89D8.2060602@sw.ru>
References: <20071221090043.GA25484@iris.sw.ru> <20071221.013321.164620125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, devel@openvz.org, netdev@vger.kernel.org,
	kaber@trash.net, kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:62401 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752360AbXLUJh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 04:37:29 -0500
In-Reply-To: <20071221.013321.164620125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Fri, 21 Dec 2007 12:00:43 +0300
> 
>> nl_fib_input re-reuses incoming skb to send the reply. This means that this
>> packet will be freed twice, namely in:
>> - netlink_unicast_kernel
>> - on receive path
>> Use clone to send as a cure, the caller is responsible for kfree_skb on error.
>>
>> Thanks to Alexey Dobryan, who originally found the problem.
>>
>> Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> What introduced this bug?  This code didn't have this
> problem previously.
> 

commit cd40b7d3983c708aabe3d3008ec64ffce56d33b0
Author: Denis V. Lunev <den@openvz.org>
Date:   Wed Oct 10 21:15:29 2007 -0700
