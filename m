From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv4: ip_send_unicast_reply should set oif only if
 it is L3 master
Date: Wed, 9 Nov 2016 19:52:22 -0700
Message-ID: <bd19302c-8ae9-efd6-dbb6-66c7bc1b2a82@cumulusnetworks.com>
References: <1478645431-7454-1-git-send-email-dsa@cumulusnetworks.com>
 <20161109.214824.929135741139951182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:32804 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753021AbcKJCxU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 21:53:20 -0500
Received: by mail-pf0-f180.google.com with SMTP id d2so137532699pfd.0
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 18:52:24 -0800 (PST)
In-Reply-To: <20161109.214824.929135741139951182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/9/16 7:48 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Tue,  8 Nov 2016 14:50:31 -0800
> 
>> Lorenzo noted an Android unit test failed due to commit e0d56fdd7342:
>>   "The expectation in the test was that the RST replying to a SYN sent to a
>>   closed port should be generated with oif=0. In other words it should not
>>   prefer the interface where the SYN came in on, but instead should follow
>>   whatever the routing table says it should do."
>>
>> Since this a change in behavior, revert the change to
>> ip_send_unicast_reply such that the oif in the flow is set to the skb_iif
>> only if skb_iif is an L3 master.
>>
>> Fixes: e0d56fdd7342 ("net: l3mdev: remove redundant calls")
>> Reported-by: Lorenzo Colitti <lorenzo@google.com>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> David, I'm assuming that a new spin of this patch is coming.
> 

yes. posted this morning; Lorenzo tested and ack'ed an hour or so ago. Since it expanded to include IPv6, the subject line changed so it won't be readily apparent.
