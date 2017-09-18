From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: fix regression of no RTM_DELADDR sent after
 DAD failure
Date: Mon, 18 Sep 2017 14:06:40 +0100
Message-ID: <ce045f3d-c99a-e9a2-a0e7-c4d0410f0665@brocade.com>
References: <1504536775-23533-1-git-send-email-mmanning@brocade.com>
 <20170907.191843.836588795188250550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "maheshb@google.com" <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:41138 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754820AbdIRNtg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 09:49:36 -0400
In-Reply-To: <20170907.191843.836588795188250550.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
In the absence of a reply from Mahesh, I would be most grateful for
anyone familiar with the IPv6 code to review this 1-line fix.

Or if not, then I request that the commit f784ad3d79e5 is backed out,
as its intention is to remove the redundant but harmless RTM_DELADDR
for addresses in tentative state, but is also incorrectly removing the
very necessary RTM_DELADDR when an address is deleted that was previously
notified with an RTM_NEWADDR as being in tentative dadfailed state.

Thanks
Mike

On 08/09/17 03:18, David Miller wrote:
> From: Mike Manning <mmanning@brocade.com>
> Date: Mon,  4 Sep 2017 15:52:55 +0100
> 
>> Commit f784ad3d79e5 ("ipv6: do not send RTM_DELADDR for tentative
>> addresses") incorrectly assumes that no RTM_NEWADDR are sent for
>> addresses in tentative state, as this does happen for the standard
>> IPv6 use-case of DAD failure, see the call to ipv6_ifa_notify() in
>> addconf_dad_stop(). So as a result of this change, no RTM_DELADDR is
>> sent after DAD failure for a link-local when strict DAD (accept_dad=2)
>> is configured, or on the next admin down in other cases. The absence
>> of this notification breaks backwards compatibility and causes problems
>> after DAD failure if this notification was being relied on. The
>> solution is to allow RTM_DELADDR to still be sent after DAD failure.
>>
>> Fixes: f784ad3d79e5("ipv6: do not send RTM_DELADDR for tentative addresses")
>> Signed-off-by: Mike Manning <mmanning@brocade.com>
>> Cc: Mahesh Bandewar <maheshb@google.com>
> 
> Mahesh, please review this patch.
> 
