From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 12/15] ipv4: fib: Notify about nexthop status
 changes
Date: Wed, 8 Feb 2017 17:32:26 +0200
Message-ID: <20170208153226.GA24185@splinter.mtl.com>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
 <1486549002-2056-13-git-send-email-jiri@resnulli.us>
 <20170208145600.GA48568@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>, <eladr@mellanox.com>, <mlxsw@mellanox.com>,
        "Roopa Prabhu" <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40076.outbound.protection.outlook.com ([40.107.4.76]:56985
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753928AbdBHPue (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 10:50:34 -0500
Content-Disposition: inline
In-Reply-To: <20170208145600.GA48568@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 09:56:00AM -0500, Andy Gospodarek wrote:
> On Wed, Feb 08, 2017 at 11:16:39AM +0100, Jiri Pirko wrote:
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > When a multipath route is hit the kernel doesn't consider nexthops that
> > are DEAD or LINKDOWN when IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN is set.
> > Devices that offload multipath routes need to be made aware of nexthop
> > status changes. Otherwise, the device will keep forwarding packets to
> > non-functional nexthops.
> > 
> > Add the FIB_EVENT_NH_{ADD,DEL} events to the fib notification chain,
> > which notify capable devices when they should add or delete a nexthop
> > from their tables.
> 
> This looks good -- thanks for doing this.
> 
> IIUC the hardware forwarding use case for your hardware covered by David
> Ahern's patch[1] to the ipv4 software path selection is already covered,
> so this is probably the last known link/neighbor forwarding issue for
> ipv4 that needs coverage.
> 
> 1. a6db449 net: ipv4: Consider failed nexthops in multipath routes

Yep, it aligns the kernel's datapath with what we already implemented in
mlxsw. In case the neighbour can't be resolve, then the nexthop isn't
reflected to the device (we need the MAC...).

In the case of multipath routes, if some of the nexthops can be
reflected, then we do so, but periodically ask the kernel to try and
resolve the others. Otherwise, these nexthops will never be resolved, as
the kernel doesn't see the packets hitting the multipath route and
therefore lacks the motivation to resolve its nexthops.

> > Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> > Cc: David Ahern <dsa@cumulusnetworks.com>
> > Cc: Andy Gospodarek <andy@greyhouse.net>
> 
> Reviewed-by: Andy Gospodarek <gospo@broadcom.com>

Thanks for reviewing!
