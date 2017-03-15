From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash
 policy choice
Date: Tue, 14 Mar 2017 17:24:24 -0700 (PDT)
Message-ID: <20170314.172424.1077779028779735713.davem@davemloft.net>
References: <8088fe5f-0c0b-bdba-4fba-e9e28bbed02e@cumulusnetworks.com>
        <20170314.114837.619141079617104809.davem@davemloft.net>
        <20170314132506.6233b1e7@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        jkbs@redhat.com, edumazet@google.com, pch@ordbogen.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58358 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdCOAY2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 20:24:28 -0400
In-Reply-To: <20170314132506.6233b1e7@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 14 Mar 2017 13:25:06 -0700

> On Tue, 14 Mar 2017 11:48:37 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> Date: Tue, 14 Mar 2017 17:58:46 +0200
>> 
>> > On 14/03/17 17:55, Stephen Hemminger wrote:  
>> >> On Tue, 14 Mar 2017 17:36:15 +0200
>> >> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>> >>   
>> >>> This patch adds support for ECMP hash policy choice via a new sysctl
>> >>> called fib_multipath_hash_policy and also adds support for L4 hashes.
>> >>> The current values for fib_multipath_hash_policy are:
>> >>>  0 - layer 3 (default)
>> >>>  1 - layer 4
>> >>> If there's an skb hash already set and it matches the chosen policy then it
>> >>> will be used instead of being calculated (currently only for L4).
>> >>> In L3 mode we always calculate the hash due to the ICMP error special
>> >>> case, the flow dissector's field consistentification should handle the
>> >>> address order thus we can remove the address reversals.
>> >>>
>> >>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>  
>> >> 
>> >> It is good to see ECMP come back from the grave.
>> >> Linux used to support it long ago but was abandoned after it was unstable
>> >> and removed from iproute2 in 2012.
>> >> 
>> >> The old API was through route attributes which makes more sense than
>> >> doing it with sysctl. It makes more sense to use netlink instead.
>> >> Therefore please go back and do something like the old API rather than doing it through
>> >> sysctl.
>> >>   
>> > 
>> > That's what my initial version did, but this was discussed during NetConf in Seville
>> > and it was decided that it's best to make a global sysctl, thus the change.  
>> 
>> Correct, we discussed this, and we all agreed to only have a sysctl for now.
> 
> Why? If you are going to have private discussions please post the rationale
> in public.

The idea is that we couldn't come up with an immediate use case, and if one
came up we could easily add the per-route or per-fib-table attribute.

Most people want the entire system to behave a certain way wrt. ECMP, rather
than have fine granularity.  For example, the case being discussed here is
to simply have software's behavior match that of hardware offloads.

We shouldn't add things until there is a real demonstrated and requested need.
