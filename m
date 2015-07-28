From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4] af_mpls: fix undefined reference to ip6_route_output
Date: Tue, 28 Jul 2015 09:16:17 -0700
Message-ID: <55B7AAD1.7010603@cumulusnetworks.com>
References: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com> <55B78EFD.1030306@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35710 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbbG1QQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 12:16:19 -0400
Received: by pabkd10 with SMTP id kd10so72229704pab.2
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 09:16:19 -0700 (PDT)
In-Reply-To: <55B78EFD.1030306@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/28/15, 7:17 AM, Robert Shearman wrote:
> On 28/07/15 07:40, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Undefined reference to ip6_route_output and ip_route_output
>> was reported with CONFIG_INET=n and CONFIG_IPV6=n.
>>
>> This patch adds new CONFIG_MPLS_NEXTHOP_DEVLOOKUP
>> to lookup nexthop device if user has not specified it
>> in RTA_OIF attribute. Make CONFIG_MPLS_NEXTHOP_DEVLOOKUP
>> depend on INET and (IPV6 || IPV6=n) because it
>> uses ip6_route_output and ip_route_output.
>>
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Reported-by: Thomas Graf <tgraf@suug.ch>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Is there a compelling reason to allow the user/applications to not 
> specify the output interface and to derive it from the nexthop? If the 
> user/application intends to treat this as a recursive route then it 
> has to make sure to trigger route updates to the kernel anyway, and an 
> application should have the output interface and real nexthop close to 
> hand in that case.

RTA_OIF is optional for ipv4 and ipv6 routes and we wanted to keep it 
that way for mpls routes as well (Quagga is the application in our use 
case).
It was a simple patch...until i realized the IPV6 dependency issues (I 
will sure remember this next time).

>
> If there isn't a compelling reason, then perhaps the best course of 
> action is to revert the commit, instead of introducing a level of 
> config complexity that means that users/applications may not be able 
> to rely on this capability anyway?
The config option though looks complex should not introduce any 
complexity for the user. It is on by default and always on for the 
default case.
Only for the cases where the IPV6 is a loaded as a module and 
MPLS_ROUTING is not, the app may get family not supported errors.
I did suggest a revert the first time. Mainly for me to fix the mistake 
i made and resubmit after proper IPV6 dependency testing.

I am in the process of trying the option that hannes suggested.

Thanks,
Roopa
