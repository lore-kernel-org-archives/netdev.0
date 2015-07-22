From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to ip6_route_output
Date: Wed, 22 Jul 2015 12:30:22 -0700
Message-ID: <55AFEF4E.9060003@cumulusnetworks.com>
References: <1437549003-35563-1-git-send-email-roopa@cumulusnetworks.com> <20150722122309.GB968@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35523 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbbGVTaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 15:30:24 -0400
Received: by pdrg1 with SMTP id g1so143364511pdr.2
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 12:30:24 -0700 (PDT)
In-Reply-To: <20150722122309.GB968@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/22/15, 5:23 AM, Thomas Graf wrote:
> On 07/22/15 at 12:10am, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> seen with CONFIG_IPV6 disabled. Wrap the code
>> around IS_ENABLED(CONFIG_IPV6)
>>
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> We need the same for CONFIG_INET=n in inet_fib_lookup_dev:
>
> /home/tgraf/dev/linux/net-next/include/net/route.h:122: undefined reference to `ip_route_output_flow'
  I will fix it.
>
> Is it worth returning EAFNOSUPPORT instead of ENODEV in these
> cases?  Something like this:

sure, I am ok with changing it to return EAFNOSUPPORT.
I decided on -ENODEV because I was already sending -ENODEV
for cases where the dev cannot be resolved.

>
>>   }
>> +#else
>> +static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
>> +{
>   +	return ERR_PTR(-EAFNOSUPPORT);
>> +}
>> +#endif
> And then IS_ERR() in mpls_route_add()?
