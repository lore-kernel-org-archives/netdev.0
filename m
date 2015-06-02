From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Tue, 02 Jun 2015 08:31:24 -0700
Message-ID: <556DCC4C.7010808@cumulusnetworks.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@suug.ch>,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35503 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759309AbbFBPb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 11:31:27 -0400
Received: by igbyr2 with SMTP id yr2so89744001igb.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 08:31:27 -0700 (PDT)
In-Reply-To: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/15, 9:46 AM, Robert Shearman wrote:
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
>
> RFC because:
>   - IPv6 side not implemented
>   - struct rtable shouldn't be bloated by pointer+uint
>   - Hasn't been thoroughly tested yet
>
> Robert Shearman (3):
>    net: infra for per-nexthop encap data
>    ipv4: storing and retrieval of per-nexthop encap
>    mpls: new ipmpls device for encapsulating IP packets as mpls
>
>
Glad to see these patches!.
I have a similar series i have been working on...but no netdevice.
A set of ops similar to iptun_encaps and I store encap data in fib_nh
and in ip_route_output_slow i point the dst.output to the output func 
provided by one of the encap ops.

I see the advantages of using a netdevice...and i see this align with 
patches from thomas.
