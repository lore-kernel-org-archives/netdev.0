From: Erez Shitrit <erezsh@mellanox.com>
Subject: Re: [PATCH V2 06/12] net/core: Add rtnetlink support to vif parameters
Date: Thu, 2 Aug 2012 18:29:15 +0300
Message-ID: <501A9CCB.7020704@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>  <1343840975-3252-7-git-send-email-ogerlitz@mellanox.com> <1343866837.2602.64.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:36878 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750924Ab2HBPaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 11:30:03 -0400
In-Reply-To: <1343866837.2602.64.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/2012 3:20 AM, Ben Hutchings wrote:
> On Wed, 2012-08-01 at 20:09 +0300, Or Gerlitz wrote:
>> From: Erez Shitrit <erezsh@mellanox.co.il>
>>
>> Add IFLA_VIF_INFO which allows user space to configure mac/vlan for a VIF
> [...]
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -780,7 +780,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>>   	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
>>   	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
>>   	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>> -	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
>> +	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
>> +	       + nla_total_size(sizeof(struct ifla_vif_param)); /* IFLA_VIF_INFO */
>>   }
> [...]
>
> if_nlmsg_size() returns the size of a message describing the interface.
> But IFLA_VIF_INFO is write-only (why?) and therefore shouldn't be
> included.
>
> Ben.

thanks, we missed that.
currently, we don't expose the vifs on its parent interface, we need to 
think if we want to expose it, if yes we will add "get" option, 
otherwise we will take it from if_nlmsg_size() function.
