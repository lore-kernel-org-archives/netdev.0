From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH v2] bonding: ban stacked bonding support
Date: Fri, 20 Mar 2015 14:02:17 -0700
Message-ID: <28755.1426885337@famine>
References: <22754.1424474040@famine> <20150320174308.GA2005@p183.telecom.by> <20150320174638.GA2053@p183.telecom.by> <20150320.163845.164991966900600650.davem@davemloft.net>
Cc: adobriyan@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:52025 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbCTVCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:02:23 -0400
In-reply-to: <20150320.163845.164991966900600650.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Alexey Dobriyan <adobriyan@gmail.com>
>Date: Fri, 20 Mar 2015 20:46:38 +0300
>
>> If you add bonding master as a slave, and then release it,
>> it will no longer be an IFF_BONDING creating problems like described at
>> https://bugzilla.kernel.org/show_bug.cgi?id=89541
>> 
>> 	echo +bond1 >/sys/class/net/bonding_masters
>> 	echo 1 >/sys/class/net/bond1/bonding/mode
>> 	echo +bond2 >/sys/class/net/bonding_masters
>> 	echo +bond2 >/sys/class/net/bond1/bonding/slaves
>> 	echo -bond2 >/sys/class/net/bond1/bonding/slaves
>> 	echo -bond2 >/sys/class/net/bonding_masters
>> 
>> 	cat /proc/net/bonding/bond2	# should not exist
>> 		[oops]
>> 
>> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>
>I feel like this has been brought up before and it was stated that
>some people are actually using things like this.
>
>I could be mistaken.

	I don't think you are.  I did a bit of checking after the
discussion last month and found a few relatively recent statements that
people were nesting bonds and it was apparently working, e.g.,

http://www.alexwitherspoon.com/debian-nested-bonded-interfaces/

	which, ironically, is exactly the case that would benefit from
not nesting the bonds, as 802.3ad would handle multiple aggregators
itself.

	However, there is also this discussion

http://lists.openwall.net/netdev/2011/01/22/66

	from netdev in 2011 that states that the ingress path of nested
bonds does not work, at least for the case described.  Perhaps some
configurations work and some don't.

	Let me see if I can run a quick test and see if this actually
works for me...

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
