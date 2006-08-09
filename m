From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH][IPV6]: Make sure fib6_rule_lookup doesn't return NULL
Date: Wed, 9 Aug 2006 11:23:11 +0200
Message-ID: <20060809092311.GU14627@postel.suug.ch>
References: <20060808221651.GS14627@postel.suug.ch> <20060808.164345.91207648.davem@davemloft.net> <44D98133.8040707@tcs.hut.fi> <20060808.233442.41636358.davem@davemloft.net> <44D99E73.1060305@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:21651 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030606AbWHIJWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 05:22:51 -0400
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Content-Disposition: inline
In-Reply-To: <44D99E73.1060305@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-08-09 11:36
> Of the three original route lookup functions (ip6_route_input,
> ip6_route_output and rt6_lookup), rt6_lookup was the only one that was
> allowed to produce a NULL entry. Of these three rt6_lookup was also the
> only one not actually being used for routing.
> 
> The function that absolutely requires ip6_null_entry is ip6_route_input.

It would mean to change the logic of handling route errors like in the
IPv4 path and not handle them in .input/.output. Instead of a dst we'd
return a valid dst or a ERR_PTR() which would force the caller to take
appropriate actions such as updating statistics and sending ICMPs.

> There is also one more issue with ip6_null_entry: previously it has
> always been the result of an unsuccessful route lookup, now it can also
> be the result of a successful application of a FR_ACT_UNREACHABLE policy
> rule. From a networking point of view these two cases should IMO be
> considered equivalent and should therefore trigger the same response.
> This will however not be true if NULL (or an error code) is the result
> of an unsuccessful route lookup.

Both would simply result in a -ENETUNREACHABLE.
