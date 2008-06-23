From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH]: SCTP length validation.
Date: Mon, 23 Jun 2008 11:59:43 -0400
Message-ID: <485FC86F.4090808@hp.com>
References: <20080620.221205.183623344.davem@davemloft.net>	<485D2467.7020300@hp.com> <20080622.123232.71141502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:8719 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562AbYFWQAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 12:00:10 -0400
In-Reply-To: <20080622.123232.71141502.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Sat, 21 Jun 2008 11:55:19 -0400
> 
>> The same vulnerability also exists in sctp_getsockopt_peer_addrs_old().
>> It's a bit more difficult to trigger since there is a dependency on
>> the peer being multihomed as well, but it's still possible to cause the
>> overwrite.
> 
> I can't see how that's possible.  This case looks harmless to
> me.
> 
> The kernel side accesses are perfectly protected.  The kernel
> will only access the actual address list stored via:
> 
> 	list_for_each_entry(from, &asoc->peer.transport_addr_list,
> 				transports) {
>  ...
> 		cnt ++;
> 		if (cnt >= getaddrs.addr_num) break;
> 	}
> 	getaddrs.addr_num = cnt;
> 
> Copies are only made to userspace, and the given ->addr_num only
> serves as an early break-out from that loop.  I mean, take a look,
> those lines in the above are the only aaccesses made to the user's
> provided addr_num value.
> 
> There is no possibility to use strange ->addr_num values
> in order to read or write kernel memory outside of the
> intended bounds.
> 
> I don't even see any value to adding new checks here.
> 

You are right.  I didn't look far enough.  Since there is no kmalloc(),
the overflow of kernel memory is not possible, and copy_to_user should
take care of any overflows of the user memory.

-vlad

