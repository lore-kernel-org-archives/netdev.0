From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Tue, 02 Jun 2015 13:30:50 -0500
Message-ID: <87y4k2ufmt.fsf@x220.int.ebiederm.org>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
	<556DCC4C.7010808@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:39958 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbbFBSfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 14:35:53 -0400
In-Reply-To: <556DCC4C.7010808@cumulusnetworks.com>
	(roopa@cumulusnetworks.com's message of "Tue, 02 Jun 2015 08:31:24
	-0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roopa <roopa@cumulusnetworks.com> writes:

> On 6/1/15, 9:46 AM, Robert Shearman wrote:
>> In order to be able to function as a Label Edge Router in an MPLS
>> network, it is necessary to be able to take IP packets and impose an
>> MPLS encap and forward them out. The traditional approach of setting
>> up an interface for each "tunnel" endpoint doesn't scale for the
>> common MPLS use-cases where each IP route tends to be assigned a
>> different label as encap.
>>
>> The solution suggested here for further discussion is to provide the
>> facility to define encap data on a per-nexthop basis using a new
>> netlink attribue, RTA_ENCAP, which would be opaque to the IPv4/IPv6
>> forwarding code, but interpreted by the virtual interface assigned to
>> the nexthop.
>>
>> A new ipmpls interface type is defined to show the use of this
>> facility to allow IP packets to be imposed with an MPLS
>> encap. However, the facility is designed to be general enough to be
>> used by any encapsulation/tunneling mechanism that has similar
>> requirements of high-scale, high-variation-of-encap.
>>
>> RFC because:
>>   - IPv6 side not implemented
>>   - struct rtable shouldn't be bloated by pointer+uint
>>   - Hasn't been thoroughly tested yet
>>
>> Robert Shearman (3):
>>    net: infra for per-nexthop encap data
>>    ipv4: storing and retrieval of per-nexthop encap
>>    mpls: new ipmpls device for encapsulating IP packets as mpls
>>
>>
> Glad to see these patches!.
> I have a similar series i have been working on...but no netdevice.
> A set of ops similar to iptun_encaps and I store encap data in fib_nh
> and in ip_route_output_slow i point the dst.output to the output func provided
> by one of the encap ops.
>
> I see the advantages of using a netdevice...and i see this align with patches
> from thomas.

roopa I think I would prefer your patches.  I thinking using a netdevice
the way Robert is proposing is quite possibly a mess, from a scalability
stand point.

Do you mean ip_route_input_slow?  There is no ip_route_output_slow.

Eric
