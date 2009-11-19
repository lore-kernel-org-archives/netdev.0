From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] macvlan: export macvlan mode through netlink
Date: Thu, 19 Nov 2009 15:38:36 +0100
Message-ID: <4B05586C.5020308@trash.net>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <1258497551-25959-4-git-send-email-arnd@arndb.de> <4B0398D4.8030904@gmail.com> <200911181059.45331.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43825 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbZKSOic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 09:38:32 -0500
In-Reply-To: <200911181059.45331.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> On Wednesday 18 November 2009, Eric Dumazet wrote:
>>> --- a/drivers/net/macvlan.c
>>> +++ b/drivers/net/macvlan.c
>>> @@ -33,12 +33,6 @@
>>>  
>>>  #define MACVLAN_HASH_SIZE    (1 << BITS_PER_BYTE)
>>>  
>>> -enum macvlan_type {
>>> -     MACVLAN_PRIVATE         = 1,
>>> -     MACVLAN_VEPA            = 2,
>>> -     MACVLAN_BRIDGE          = 4,
>>> -};
>> I realize you defined MACVLAN_PRIVATE in patch 2, but used MACVLAN_MODE_PRIVATE,
>> so patch 2 is not compilable and breaks bisection ?
>>
> 
> Hmm, right. I'll fix that up as well.

> +enum ifla_macvlan_mode {
> +	MACVLAN_MODE_PRIVATE = 1, /* don't talk to other macvlans */
> +	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
> +	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
> +};

Please also keep the enum named something without ifla_ since
the mode values themselves are not netlink attributes. Just
macvlan_mode seems fine.
