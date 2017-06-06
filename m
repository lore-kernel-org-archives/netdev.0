From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: bridge: fix potential NULL pointer dereference
Date: Mon, 05 Jun 2017 22:13:05 -0500
Message-ID: <20170605221305.Horde.4htygGCbecROO4VYJ2wWHiX@gator4166.hostgator.com>
References: <20170605213030.GA6272@embeddedgus>
 <840022de-3d31-4f62-aaaf-ba83d5c78ad7@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        roopa <roopa@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway21.websitewelcome.com ([192.185.45.163]:41624 "EHLO
        gateway21.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751194AbdFFDTO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 23:19:14 -0400
Received: from cm3.websitewelcome.com (unknown [108.167.139.23])
        by gateway21.websitewelcome.com (Postfix) with ESMTP id 37C95400E5776
        for <netdev@vger.kernel.org>; Mon,  5 Jun 2017 22:13:07 -0500 (CDT)
In-Reply-To: <840022de-3d31-4f62-aaaf-ba83d5c78ad7@cumulusnetworks.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikolay,

Quoting Nikolay Aleksandrov <nikolay@cumulusnetworks.com>:

> On 06/06/17 00:30, Gustavo A. R. Silva wrote:
>> Add NULL check before dereferencing pointer _p_ inside br_afspec().
>>
>> Addresses-Coverity-ID: 1401872
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> ---
>>  net/bridge/br_netlink.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 1e63ec4..ad85a9c 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -776,7 +776,7 @@ int br_setlink(struct net_device *dev, struct  
>> nlmsghdr *nlh, u16 flags)
>>  			goto out;
>>  	}
>>
>> -	if (afspec) {
>> +	if (p && afspec) {
>>  		err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
>>  				afspec, RTM_SETLINK);
>>  	}
>>
>
> While I see a possible issue with the new bridge tunnel code (+CC  
> Roopa), this is
> the wrong fix because there are legitimate use cases where p is null  
> and br_afspec
> is called.
> We need to change the p->flags check in br_afspec()'s  
> IFLA_BRIDGE_VLAN_TUNNEL_INFO case
> to check for a NULL p first.
>

You're right. I got it.

> Thanks for the report!

Sure thing, glad to help.

Thank you!
