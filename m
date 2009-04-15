From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses	dev_addr_list
Date: Wed, 15 Apr 2009 13:22:32 +0200
Message-ID: <49E5C378.9020209@trash.net>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090415081720.GA21342@psychotron.englab.brq.redhat.com> <20090415081819.GB21342@psychotron.englab.brq.redhat.com> <49E59A1C.9030108@cn.fujitsu.com> <20090415083223.GF21342@psychotron.englab.brq.redhat.com> <49E5A896.90408@cosmosbay.com> <20090415111724.GG21342@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, Li Zefan <lizf@cn.fujitsu.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	mschmidt@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57070 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbZDOLWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:22:44 -0400
In-Reply-To: <20090415111724.GG21342@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:

>> Since you obviously need a write lock here to be sure following
>> can be done by one cpu only.
>>
>> You have same problem all over this patch.
> 
> Yes, as Dave wrote, this is guarded by RTNL mutex.

This was incorrect. IPv6 adds multicast addresses in softirq context.

>>> +
>>> +	ha = kzalloc(sizeof(*ha), GFP_ATOMIC);
>> kzalloc(max(sizeof(*ha), L1_CACHE_SIZE), GFP_...) is thus higly recommended here.
>>
>> Also, why GFP_ATOMIC is needed here ?
> 
> Yes, it is not needed here. I've copied it here from the original unicast and
> multicast add funtion to stay close but as I can see, there is no need for it
> there either.
> Noted.

Also needed for IPv6 in softirq context.

