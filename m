From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to
 ip6_route_output
Date: Wed, 22 Jul 2015 10:49:26 -0700 (PDT)
Message-ID: <20150722.104926.1502608671575195516.davem@davemloft.net>
References: <1437549003-35563-1-git-send-email-roopa@cumulusnetworks.com>
	<20150722122309.GB968@pox.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756070AbbGVRt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 13:49:27 -0400
In-Reply-To: <20150722122309.GB968@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Jul 2015 14:23:09 +0200

> On 07/22/15 at 12:10am, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> 
>> seen with CONFIG_IPV6 disabled. Wrap the code
>> around IS_ENABLED(CONFIG_IPV6)
>> 
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> We need the same for CONFIG_INET=n in inet_fib_lookup_dev:
> 
> /home/tgraf/dev/linux/net-next/include/net/route.h:122: undefined reference to `ip_route_output_flow'
> 
> Is it worth returning EAFNOSUPPORT instead of ENODEV in these
> cases?  Something like this:
> 
>>  }
>> +#else
>> +static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
>> +{
>  +	return ERR_PTR(-EAFNOSUPPORT);
>> +}
>> +#endif
> 
> And then IS_ERR() in mpls_route_add()?

Also IS_ENABLED() _DOES NOT_ work, what if MPLS is 'y' and IPV6 is 'm'?

You can't reache the modular symbol from statically built code.

What a mess.
