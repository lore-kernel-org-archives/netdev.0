From: Patrick McHardy <kaber@trash.net>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 16:45:48 +0200
Message-ID: <48F0BC1C.5020005@trash.net>
References: <48EF7D24.6040400@trash.net> <20081011103935.GA6168@gondor.apana.org.au> <48F0BB77.6080401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51605 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401AbYJKOpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 10:45:51 -0400
In-Reply-To: <48F0BB77.6080401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Herbert Xu wrote:
>>> I noticed the interface expects to always get a full configuration
>>> on change requests. Is there are particular reason for not
>>> supporting incremental changes, lets say
>>>
>>> "ip link change dev gre0 type gre remote <new remote>"
>>>
>>> ? It looks easy enough to change, so I could take care of this.
>>
>> I think this should be done in iproute.  That way the user (or
>> rather the user-space programmer) gets to choose the behaviour.
>> This is also how the existing interface works too.
> 
> We don't have much precedent for rtnl_link besides VLAN (which
> does support incremental changes), but actually all other route
> netlink interfaces do support incremental changes by sending only
> a subset of the attributes. A reason for supporting this in the
> interface is that incremental userspace changes will always be
> racy because you need two seperate operations.


Its actually also what defines the difference between using
NLM_F_REPLACE (ip link replace) and no flags (ip link change).
The former replaces the replaces the object, the later changes
an existing object.

