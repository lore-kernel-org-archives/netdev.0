From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 12:43:27 -0700 (PDT)
Message-ID: <20170407.124327.626442219286333933.davem@davemloft.net>
References: <1491591552.5800.1.camel@sipsolutions.net>
        <20170407.122053.201153373954521345.davem@davemloft.net>
        <20170407193550.GA23424@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, jiri@resnulli.us
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933568AbdDGTn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 15:43:29 -0400
In-Reply-To: <20170407193550.GA23424@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 7 Apr 2017 21:35:50 +0200

> On Fri, Apr 07, 2017 at 12:20:53PM -0700, David Miller wrote:
> [...]
>> Let's just discuss the UAPI, since people complain we don't talk
>> about that enough :-)  For those playing at home it is three new
>> attributes returned in a netlink ACK when the application asks
>> for the extended response:
>> 
>> 	NLMSGERR_ATTR_MSG	string	Extended error string
>> 	NLMSGERR_ATTR_OFFS	u32	Byte offset to netlink element causing error
>> 	NLMSGERR_ATTR_CODE	u32	Subsystem specific error code
>> 	NLMSGERR_ATTR_ATTR	u16	Netlink attribute triggering error or missing
> 
> I think it would be good if we get a definition to cap the maximum
> string length to something reasonable? This can be added in a follow
> up patch BTW. Thus, we get people coming back to us and request larger
> strings with a reason why they need more room for this.
> 
> In general, my main concern with strings is that they can be used in a
> more freely way than these u32 offsets and error codes, and
> specifically how inconsistent these string will look like across
> different netlink subsystems.
> 
> Anyway, as long as this is optional (not every subsystem if forced to
> use strings) I'm fine with it :).

I have no strong opinions about string length.

In my opinion, I would like to believe that if someone tried to get a
networking patch applied that emitted a rediculously long string then
we would give them feedback about how that is not acceptable.  Right?

I suspect that someone will eventually give us a hard time about the
strings wrt. internationalization. :-) It's solvable at least
partially in userspace I suppose.
