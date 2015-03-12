From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next ] mpls: In mpls_egress verify the packet length.
Date: Thu, 12 Mar 2015 17:50:53 -0500
Message-ID: <87h9tpzv76.fsf@x220.int.ebiederm.org>
References: <5500BB5E.4070909@brocade.com>
	<87385a13jz.fsf@x220.int.ebiederm.org>
	<87wq2mym03.fsf_-_@x220.int.ebiederm.org>
	<20150312.182558.447886504045770209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rshearma@brocade.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [166.70.13.232] ([166.70.13.232]:42735 "EHLO
	out02.mta.xmission.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755176AbbCLWyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 18:54:55 -0400
In-Reply-To: <20150312.182558.447886504045770209.davem@davemloft.net> (David
	Miller's message of "Thu, 12 Mar 2015 18:25:58 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 12 Mar 2015 15:54:52 -0500
>
>> Robert Shearman noticed that mpls_egress is failing to verify that
>> the bytes to be examined are in fact present in the packet before
>> mpls_egress reads those bytes.
>> 
>> Reported-by: Robert Shearman <rshearma@brocade.com>
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> Let's see if we can consolidate these pskb_may_pull() calls into one,
> in the fast path they are relatively cheap but not zero cost.

> The caller (mpls_forward()) is doing one as well.
>
> All you care about is the version field and the hop_limit/ttl.
>
> For ipv4, version is in byte 0, and ttl is in byte 9.
By my count the ttl is in byte 8, and more importantly the
header checksum is in byte 10.

> For ipv6, version is also in byte zero and hop_limit is in byte 7.
>
> Therefore if you do pskb_may_pull(skb, 10) it will cover all cases
> whilst not exceeding the size of either protocol's total header.

Using the value of 12 that seems very reasonable.

> Above the pskb_may_pull() call can add a big comment explaining what
> you are doing and why this is sufficient.

Will do.

Eric
