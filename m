From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy
 choice
Date: Tue, 14 Mar 2017 17:58:46 +0200
Message-ID: <8088fe5f-0c0b-bdba-4fba-e9e28bbed02e@cumulusnetworks.com>
References: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com>
 <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170314085502.47d48a4e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        jkbs@redhat.com, edumazet@google.com, pch@ordbogen.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:32847 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750852AbdCNP6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 11:58:49 -0400
Received: by mail-wr0-f172.google.com with SMTP id u48so127178877wrc.0
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 08:58:48 -0700 (PDT)
In-Reply-To: <20170314085502.47d48a4e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/03/17 17:55, Stephen Hemminger wrote:
> On Tue, 14 Mar 2017 17:36:15 +0200
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> This patch adds support for ECMP hash policy choice via a new sysctl
>> called fib_multipath_hash_policy and also adds support for L4 hashes.
>> The current values for fib_multipath_hash_policy are:
>>  0 - layer 3 (default)
>>  1 - layer 4
>> If there's an skb hash already set and it matches the chosen policy then it
>> will be used instead of being calculated (currently only for L4).
>> In L3 mode we always calculate the hash due to the ICMP error special
>> case, the flow dissector's field consistentification should handle the
>> address order thus we can remove the address reversals.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> It is good to see ECMP come back from the grave.
> Linux used to support it long ago but was abandoned after it was unstable
> and removed from iproute2 in 2012.
> 
> The old API was through route attributes which makes more sense than
> doing it with sysctl. It makes more sense to use netlink instead.
> Therefore please go back and do something like the old API rather than doing it through
> sysctl.
> 

That's what my initial version did, but this was discussed during NetConf in Seville
and it was decided that it's best to make a global sysctl, thus the change.

Thanks,
 Nik
