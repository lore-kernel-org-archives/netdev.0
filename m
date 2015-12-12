From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net 1/4] mpls: validate L2 via address length
Date: Fri, 11 Dec 2015 16:08:24 -0800
Message-ID: <566B6578.2030302@cumulusnetworks.com>
References: <1449775851-20758-1-git-send-email-rshearma@brocade.com> <1449775851-20758-2-git-send-email-rshearma@brocade.com> <566B5358.4060200@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org,
	sam.h.russell@gmail.com
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36042 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbbLLAI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 19:08:26 -0500
Received: by pfbu66 with SMTP id u66so29784449pfb.3
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 16:08:26 -0800 (PST)
In-Reply-To: <566B5358.4060200@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/15, 2:51 PM, roopa wrote:
> On 12/10/15, 11:30 AM, Robert Shearman wrote:
>> If an L2 via address for an mpls nexthop is specified, the length of
>> the L2 address must match that expected by the output device,
>> otherwise it could access memory beyond the end of the via address
>> buffer in the route.
>>
>> This check was present prior to commit f8efb73c97e2 ("mpls: multipath
>> route support"), but got lost in the refactoring, so add it back,
>> applying it to all nexthops in multipath routes.
>>
>> Fixes: f8efb73c97e2 ("mpls: multipath route support")
>> Signed-off-by: Robert Shearman <rshearma@brocade.com>
>> ---
>>  net/mpls/af_mpls.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>> index c70d750148b6..3be29cb1f658 100644
>> --- a/net/mpls/af_mpls.c
>> +++ b/net/mpls/af_mpls.c
>> @@ -534,6 +534,10 @@ static int mpls_nh_assign_dev(struct net *net, struct mpls_route *rt,
>>  	if (!mpls_dev_get(dev))
>>  		goto errout;
>>  
>> +	if ((nh->nh_via_table == NEIGH_LINK_TABLE) &&
>> +	    (dev->addr_len != nh->nh_via_alen))
>> +		goto errout;
>> +
>>
> Robert, seems like the right place for this check is nla_get_via ?
never mind. This looks fine.

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks!.
