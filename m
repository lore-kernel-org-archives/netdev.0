From: Patrick McHardy <kaber@trash.net>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 16:43:03 +0200
Message-ID: <48F0BB77.6080401@trash.net>
References: <48EF7D24.6040400@trash.net> <20081011103935.GA6168@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51550 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbYJKOnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 10:43:07 -0400
In-Reply-To: <20081011103935.GA6168@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Oct 10, 2008 at 06:04:52PM +0200, Patrick McHardy wrote:
>> Some minor cleanups, there doesn't seem to be a reason for not
>> using the typeful helpers everywhere.
> 
> The reason for that was future IPv6 support.  But I suppose having
> it as a be32 for now doesn't prevent us from changing it later, or
> does it?

No, its equivalant to using memcpy.

>> I noticed the interface expects to always get a full configuration
>> on change requests. Is there are particular reason for not
>> supporting incremental changes, lets say
>>
>> "ip link change dev gre0 type gre remote <new remote>"
>>
>> ? It looks easy enough to change, so I could take care of this.
> 
> I think this should be done in iproute.  That way the user (or
> rather the user-space programmer) gets to choose the behaviour.
> This is also how the existing interface works too.

We don't have much precedent for rtnl_link besides VLAN (which
does support incremental changes), but actually all other route
netlink interfaces do support incremental changes by sending only
a subset of the attributes. A reason for supporting this in the
interface is that incremental userspace changes will always be
racy because you need two seperate operations.
