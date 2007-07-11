From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH] Virtual ethernet device (v2.1)
Date: Wed, 11 Jul 2007 16:44:53 +0400
Message-ID: <4694D0C5.6020700@openvz.org>
References: <4694A363.2070406@openvz.org> <4694CBD9.90503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Ben Greear <greearb@candelatech.com>, devel@openvz.org,
	Kirill Korotaev <dev@openvz.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:39732 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758366AbXGKMpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 08:45:11 -0400
In-Reply-To: <4694CBD9.90503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelianov wrote:
>> +static const struct nla_policy veth_policy[VETH_INFO_MAX + 1] = {
>> +	[VETH_INFO_MAC]		= { .type = NLA_BINARY, .len = ETH_ALEN },
>> +	[VETH_INFO_PEER]	= { .type = NLA_STRING },
>> +	[VETH_INFO_PEER_MAC]	= { .type = NLA_BINARY, .len = ETH_ALEN },
>> +};
> 
> 
> Looks good, just one question. What happended to the IFLA_PARTNER
> attribute idea? I have a patch to allow specifying the initial
> MAC address for a device, IFLA_PARTNER would make the whole thing
> symetrical.

Well, the notion of a partner is not applicable to any generic link
unlike the device name, physical (MAC) address or MTU value. So i 
think that it's better to keep this as a specific driver information 
not to confuse the generic code. I think it's worth making this as 
some more generic code than it is now, but since this driver is the 
only user of "partner" maybe it's better not to make it right now. 
Later, when we do know what do we want "partner" to be.

Thanks,
Pavel
