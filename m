From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v4] af_mpls: fix undefined reference to
 ip6_route_output
Date: Wed, 29 Jul 2015 12:51:19 +0200
Message-ID: <20150729105119.GE13113@pox.localdomain>
References: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com>
 <55B78EFD.1030306@brocade.com>
 <55B7AAD1.7010603@cumulusnetworks.com>
 <55B8AD24.6020205@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa <roopa@cumulusnetworks.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35508 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbbG2KvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 06:51:23 -0400
Received: by wibxm9 with SMTP id xm9so195258474wib.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 03:51:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55B8AD24.6020205@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/15 at 11:38am, Robert Shearman wrote:
> On 28/07/15 17:16, roopa wrote:
> >RTA_OIF is optional for ipv4 and ipv6 routes and we wanted to keep it
> >that way for mpls routes as well (Quagga is the application in our use
> >case).
> >It was a simple patch...until i realized the IPV6 dependency issues (I
> >will sure remember this next time).
> 
> Having read the code, I realise the nexthop isn't derived from the lookup.
> Given that this can only work for the case where a path is recursive via a
> connected nexthop, it seems to be of limited use.
> 
> I'm not familiar with the Quagga code, but is it worth adding this
> additional complexity to the kernel rather than making a change to Quagga
> instead, where presumably it already has code to derive the output interface
> in the case of having a recursive route via a non-connected nexthop?

I think it's wrong to assume that it's always a single management
application that manages both parts of the route. At least for
underlays and overlays it is fairly common to run something like
Quagga to manage the underlay and use multiple other orchestration
tools on top to create virtual networks which should not be aware of
any underlay specifics.
