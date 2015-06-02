From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Tue, 2 Jun 2015 21:57:34 +0100
Message-ID: <556E18BE.8060505@brocade.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com> <87h9qqx9n5.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Thomas Graf <tgraf@suug.ch>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:47152 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751280AbbFBU6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 16:58:36 -0400
In-Reply-To: <87h9qqx9n5.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/15 19:11, Eric W. Biederman wrote:
> Robert Shearman <rshearma@brocade.com> writes:
>
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
>
> I am still digging into the details but adding a new network device to
> make this possible if very undesirable.
>
> It is a pain point.  Those network devices get to be a major source of
> memory consumption when there are 4K network namespaces in existence.
>
> It is conceptually wrong.  The network device will never be used as an
> ordinary network device.  All the network device gives you is the
> ability to avoid creating an enumeration of different kinds of
> encapsulation.

This isn't true. The network device also gives some of the things you 
take for granted. Things like fragmentation through specifying the mtu 
on the shared tunnel device, being able to specify rules using the 
shared tunnel output device, IP stats, and the ability specify a 
different destination namespace.

Thanks,
Rob
