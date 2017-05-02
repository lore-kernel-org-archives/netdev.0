From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next iproute2 1/3] netlink: import netlink message
 parsing from kernel
Date: Tue, 02 May 2017 14:51:02 -0400 (EDT)
Message-ID: <20170502.145102.1235504926303235504.davem@davemloft.net>
References: <20170502.130032.1854491688518080191.davem@davemloft.net>
        <20170502110314.66d9ee89@xeon-e3>
        <3acddce9-5421-637e-8b2b-ae8dd5c7b29a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        jakub.kicinski@netronome.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52544 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751251AbdEBSvG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 14:51:06 -0400
In-Reply-To: <3acddce9-5421-637e-8b2b-ae8dd5c7b29a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 2 May 2017 12:39:51 -0600

> On 5/2/17 12:03 PM, Stephen Hemminger wrote:
>> Then use libmnl it is already used in several other places in iproute2.
>> Eventually, I would like to use it everywhere and get rid of old netlink parser.
>> 
> 
> Why? libmnl is not going to simplify the iproute2 code.

Agreed.

> Look at attribute validation. Importing the kernel code into iproute2,
> the API is very familiar to anyone hacking on the kernel side:
> 
> +       if (nla_parse(tb, NLMSGERR_ATTR_MAX, attr, alen, extack_policy)
> != 0) {
> +               fprintf(stderr,
> +                       "Failed to parse extended error attributes\n");
> +               return 0;
> +       }
> +
> 
> ie., you pass a policy to the parse routine and the checking is part of
> nla_parse. The implementation of nla_parse and validate_nla are quite
> easy to read.
> 
> Now take a look at what devlink has for validation - attr_cb. IMO very
> unreadable and puts the burden on the app using the libmnl API.

Also agreed.

Stephen I totally agree with David, asking him to use libmnl for this is
not reasonable nor is it even a good idea given the above.
