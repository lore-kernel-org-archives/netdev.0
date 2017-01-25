From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: ignore null_entry on route dumps
Date: Tue, 24 Jan 2017 18:35:02 -0700
Message-ID: <95b123db-a760-b73a-a858-9be0516799fc@cumulusnetworks.com>
References: <1485147377-11922-1-git-send-email-dsa@cumulusnetworks.com>
 <20170122.235829.1911961579892347071.davem@davemloft.net>
 <a1eaeddc-69df-e0fa-c06a-285c3234249c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaolong.ye@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:32958 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751013AbdAYBfE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 20:35:04 -0500
Received: by mail-pg0-f47.google.com with SMTP id 204so59662844pge.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 17:35:04 -0800 (PST)
In-Reply-To: <a1eaeddc-69df-e0fa-c06a-285c3234249c@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17 9:51 AM, David Ahern wrote:
> On 1/22/17 9:58 PM, David Miller wrote:
>> David, please slow down.
>>
>> How is the NULL entry getting selected to be dumped and passed
>> down here in the first place?
> The null_entry might be a 'marker' but is integral to the ipv6 fib.

As I mentioned in my last response the null_entry is tb6_root.leaf for all tables making it part of the table. Since the dump walks the table and sends each route to rt6_dump_route, the dump includes the null_entry.

ip6_null_entry->rt6i_idev is NULL because ip6_route_net_init is run before addrconf_init has initialized the loopback device.

Given that, it seems like a check is needed somewhere ...  be it 'rt == net->ipv6.ip6_null_entry' in rt6_dump_route or fib6_dump_node, or a check for rt6i_idev NULL in rt6_fill_node.

You marked the last patch as changes needed meaning another needs to be sent.

Suggestion?
