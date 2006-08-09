From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPV6]: Make sure fib6_rule_lookup doesn't return NULL
Date: Tue, 08 Aug 2006 23:34:42 -0700 (PDT)
Message-ID: <20060808.233442.41636358.davem@davemloft.net>
References: <20060808221651.GS14627@postel.suug.ch>
	<20060808.164345.91207648.davem@davemloft.net>
	<44D98133.8040707@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6627
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030553AbWHIGel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 02:34:41 -0400
To: vnuorval@tcs.hut.fi
In-Reply-To: <44D98133.8040707@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Wed, 09 Aug 2006 09:31:15 +0300

> But the ip6_null_entry not always discarded after a failed route lookup!
> On a forwarding router it triggers the ICMPv6 Destination Unreachable
> message to the sender.

Good point, but I remember that in some cases the caller only wants a
real entry or an error.

Perhaps both cases can be accomodated with a SHIM inline for the
forwarding case that returns &ip6_null_entry when IS_ERR(retval).
