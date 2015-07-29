From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v4] af_mpls: fix undefined reference to ip6_route_output
Date: Wed, 29 Jul 2015 12:52:50 +0100
Message-ID: <55B8BE92.7080807@brocade.com>
References: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com>
 <55B78EFD.1030306@brocade.com> <55B7AAD1.7010603@cumulusnetworks.com>
 <55B8AD24.6020205@brocade.com> <20150729105119.GE13113@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa <roopa@cumulusnetworks.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:53087 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750741AbbG2LxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 07:53:09 -0400
In-Reply-To: <20150729105119.GE13113@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/07/15 11:51, Thomas Graf wrote:
> On 07/29/15 at 11:38am, Robert Shearman wrote:
>> On 28/07/15 17:16, roopa wrote:
>>> RTA_OIF is optional for ipv4 and ipv6 routes and we wanted to keep it
>>> that way for mpls routes as well (Quagga is the application in our use
>>> case).
>>> It was a simple patch...until i realized the IPV6 dependency issues (I
>>> will sure remember this next time).
>>
>> Having read the code, I realise the nexthop isn't derived from the lookup.
>> Given that this can only work for the case where a path is recursive via a
>> connected nexthop, it seems to be of limited use.
>>
>> I'm not familiar with the Quagga code, but is it worth adding this
>> additional complexity to the kernel rather than making a change to Quagga
>> instead, where presumably it already has code to derive the output interface
>> in the case of having a recursive route via a non-connected nexthop?
>
> I think it's wrong to assume that it's always a single management
> application that manages both parts of the route. At least for
> underlays and overlays it is fairly common to run something like
> Quagga to manage the underlay and use multiple other orchestration
> tools on top to create virtual networks which should not be aware of
> any underlay specifics.

I agree, but this kernel mechanism doesn't serve that purpose in the 
general case - it only works for a connected nexthop. In other cases, 
the application creating the overlay network (assuming it's not using 
tunnels) will need to the recursive route resolution itself.

I'd like to see recursive route resolution including responding to 
changes in the via route being done in the kernel for other reasons too, 
but IMHO just the derivation of the output interface for a connected 
nexthop on the initial route add doesn't offer much benefit.

Thanks,
Rob
