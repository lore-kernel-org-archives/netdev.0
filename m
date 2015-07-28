From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v4] af_mpls: fix undefined reference to ip6_route_output
Date: Tue, 28 Jul 2015 15:17:33 +0100
Message-ID: <55B78EFD.1030306@brocade.com>
References: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <davem@davemloft.net>,
	<tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:58779 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751564AbbG1ORt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 10:17:49 -0400
In-Reply-To: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/15 07:40, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Undefined reference to ip6_route_output and ip_route_output
> was reported with CONFIG_INET=n and CONFIG_IPV6=n.
>
> This patch adds new CONFIG_MPLS_NEXTHOP_DEVLOOKUP
> to lookup nexthop device if user has not specified it
> in RTA_OIF attribute. Make CONFIG_MPLS_NEXTHOP_DEVLOOKUP
> depend on INET and (IPV6 || IPV6=n) because it
> uses ip6_route_output and ip_route_output.
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Reported-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Is there a compelling reason to allow the user/applications to not 
specify the output interface and to derive it from the nexthop? If the 
user/application intends to treat this as a recursive route then it has 
to make sure to trigger route updates to the kernel anyway, and an 
application should have the output interface and real nexthop close to 
hand in that case.

If there isn't a compelling reason, then perhaps the best course of 
action is to revert the commit, instead of introducing a level of config 
complexity that means that users/applications may not be able to rely on 
this capability anyway?

Thanks,
Rob
