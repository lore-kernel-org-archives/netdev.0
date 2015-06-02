From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Tue, 2 Jun 2015 02:06:03 +0200
Message-ID: <20150602000603.GB18435@pox.localdomain>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	roopa <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:34018 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbbFBAGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 20:06:06 -0400
Received: by wgv5 with SMTP id 5so127121101wgv.1
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 17:06:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/15 at 05:46pm, Robert Shearman wrote:
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

RTA_ENCAP is currently a binary blob specific to each encapsulation
type interface. I guess this should be converted to a set of nested
Netlink attributes for each type of encap to make it extendible in
the future.

What is your plan regarding the receive side and on the matching of
encap fields? Storing the receive parameters is what lead me to
storing it in skb_shared_info.
