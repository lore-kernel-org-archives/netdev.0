From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Tue, 02 Jun 2015 13:11:58 -0500
Message-ID: <87h9qqx9n5.fsf@x220.int.ebiederm.org>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Thomas Graf <tgraf@suug.ch>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37298 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309AbbFBSRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 14:17:03 -0400
In-Reply-To: <1433177175-16775-1-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Mon, 1 Jun 2015 17:46:12 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> In order to be able to function as a Label Edge Router in an MPLS
> network, it is necessary to be able to take IP packets and impose an
> MPLS encap and forward them out. The traditional approach of setting
> up an interface for each "tunnel" endpoint doesn't scale for the
> common MPLS use-cases where each IP route tends to be assigned a
> different label as encap.
>
> The solution suggested here for further discussion is to provide the
> facility to define encap data on a per-nexthop basis using a new
> netlink attribue, RTA_ENCAP, which would be opaque to the IPv4/IPv6
> forwarding code, but interpreted by the virtual interface assigned to
> the nexthop.
>
> A new ipmpls interface type is defined to show the use of this
> facility to allow IP packets to be imposed with an MPLS
> encap. However, the facility is designed to be general enough to be
> used by any encapsulation/tunneling mechanism that has similar
> requirements of high-scale, high-variation-of-encap.

I am still digging into the details but adding a new network device to
make this possible if very undesirable.

It is a pain point.  Those network devices get to be a major source of
memory consumption when there are 4K network namespaces in existence.

It is conceptually wrong.  The network device will never be used as an
ordinary network device.  All the network device gives you is the
ability to avoid creating an enumeration of different kinds of
encapsulation.

Eric
