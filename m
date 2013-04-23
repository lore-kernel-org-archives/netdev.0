From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] net: fix address check in rtnl_fdb_del
Date: Tue, 23 Apr 2013 17:04:46 -0400
Message-ID: <5176F76E.6070406@redhat.com>
References: <1366749559-9868-1-git-send-email-vyasevic@redhat.com> <1366750075.4016.34.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63036 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754654Ab3DWVEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 17:04:54 -0400
In-Reply-To: <1366750075.4016.34.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2013 04:47 PM, Ben Hutchings wrote:
> On Tue, 2013-04-23 at 16:39 -0400, Vlad Yasevich wrote:
>> Commit 6681712d67eef14c4ce793561c3231659153a320
>> 	vxlan: generalize forwarding tables
>>
>> relaxed the address checks in rtnl_fdb_del() to use is_zero_ether_addr().
>> This allows users to add multicast addresses using the fdb API.  However,
>> the check in rtnl_fdb_del() still uses a more strict
>> is_valid_ether_addr() which rejects multicast addresses.  Thus it
>> is possible to add an fdb that can not be later removed.
>> Relax the check in rtnl_fdb_del() as well.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   net/core/rtnetlink.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index 18af08a..2c54cc1 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2192,7 +2192,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
>>   	}
>>
>>   	addr = nla_data(tb[NDA_LLADDR]);
>> -	if (!is_valid_ether_addr(addr)) {
>> +	if (!is_zero_ether_addr(addr)) {
>
> This is the opposite of what you want.

of course you are right....  totally forgot the '!'...

Thanks
-vlad
>
> Ben.
>
>>   		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid ether address\n");
>>   		return -EINVAL;
>>   	}
>
