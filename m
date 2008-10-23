From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: fix append of whole original message on negative
 ack.
Date: Thu, 23 Oct 2008 23:02:32 +0200
Message-ID: <4900E668.9050101@trash.net>
References: <4900BFCF.2030707@gmail.com> <20081023.134513.267548182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: michellammertink@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61272 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbYJWVFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 17:05:09 -0400
In-Reply-To: <20081023.134513.267548182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: M Lammertink <michellammertink@gmail.com>
> Date: Thu, 23 Oct 2008 20:17:51 +0200
>   
>> Can anyone explain to me why struct nlmsgerr contains an int error and the nlmsghdr struct. The comment in netlink_ack states that the whole message should be appended. Why not only include an int error in struct nlmsgerr and just append the original message?
>>
>> Comments appreciated.
>>
>> diff -uprN linux-2.6.27.3.orig/net/netlink/af_netlink.c linux-2.6.27.3/net/netlink/af_netlink.c
>> --- linux-2.6.27.3.orig/net/netlink/af_netlink.c	2008-10-23 18:01:54.000000000 +0200
>> +++ linux-2.6.27.3/net/netlink/af_netlink.c	2008-10-23 18:04:22.000000000 +0200
>> @@ -1656,7 +1656,7 @@ void netlink_ack(struct sk_buff *in_skb,
>>  	}
>>  
>>  	rep = __nlmsg_put(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
>> -			  NLMSG_ERROR, sizeof(struct nlmsgerr), 0);
>> +			  NLMSG_ERROR, payload, 0)

You can't include the full message since the resulting message
might exceed the 64k netlink limit.

