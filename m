From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses
	dev_addr_list
Date: Wed, 15 Apr 2009 16:42:05 +0200
Message-ID: <20090415144204.GI21342@psychotron.englab.brq.redhat.com>
References: <49E59A1C.9030108@cn.fujitsu.com> <20090415083223.GF21342@psychotron.englab.brq.redhat.com> <49E5A896.90408@cosmosbay.com> <20090415.023104.82135803.davem@davemloft.net> <49E5B365.2010008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	mschmidt@redhat.com, ivecera@redhat.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35606 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522AbZDOOov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 10:44:51 -0400
Content-Disposition: inline
In-Reply-To: <49E5B365.2010008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 15, 2009 at 12:13:57PM CEST, kaber@trash.net wrote:
> David Miller wrote:
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Wed, 15 Apr 2009 11:27:50 +0200
>>
>>> Since you obviously need a write lock here to be sure following
>>> can be done by one cpu only.
>>>
>>> You have same problem all over this patch.
>>
>> RTNL semaphore is held across all modification operations.
>
> If this will also be used for multicast lists, changes can happen
> (IPv6) without the RTNL.

Ok, but for dev_addr_X() functions the RTNL mutex is sufficient so I see no
point of adding another lock here. When the multicast handling functions will be
implemented to use netdev_hw_addr and it's layer, then we need to use update
lock in dev_multicast_X.
