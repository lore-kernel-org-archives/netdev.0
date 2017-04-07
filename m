From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 7 Apr 2017 21:35:50 +0200
Message-ID: <20170407193550.GA23424@salvia>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
 <20170407.115315.23470877439489670.davem@davemloft.net>
 <1491591552.5800.1.camel@sipsolutions.net>
 <20170407.122053.201153373954521345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35740 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754469AbdDGTf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 15:35:57 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E3B0C170D27
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 21:35:52 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D48B9DA38C
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 21:35:52 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C09EBDA38C
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 21:35:50 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170407.122053.201153373954521345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 07, 2017 at 12:20:53PM -0700, David Miller wrote:
[...]
> Let's just discuss the UAPI, since people complain we don't talk
> about that enough :-)  For those playing at home it is three new
> attributes returned in a netlink ACK when the application asks
> for the extended response:
> 
> 	NLMSGERR_ATTR_MSG	string	Extended error string
> 	NLMSGERR_ATTR_OFFS	u32	Byte offset to netlink element causing error
> 	NLMSGERR_ATTR_CODE	u32	Subsystem specific error code
> 	NLMSGERR_ATTR_ATTR	u16	Netlink attribute triggering error or missing

I think it would be good if we get a definition to cap the maximum
string length to something reasonable? This can be added in a follow
up patch BTW. Thus, we get people coming back to us and request larger
strings with a reason why they need more room for this.

In general, my main concern with strings is that they can be used in a
more freely way than these u32 offsets and error codes, and
specifically how inconsistent these string will look like across
different netlink subsystems.

Anyway, as long as this is optional (not every subsystem if forced to
use strings) I'm fine with it :).
