From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 00:20:27 -0700 (PDT)
Message-ID: <20060428.002027.51369887.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143B020@NT-SJCA-0751.brcm.ad.broadcom.com>
	<20060428061054.GD17360@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, kelly@au1.ibm.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8330
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030283AbWD1HUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 03:20:35 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060428061054.GD17360@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Apr 2006 10:10:54 +0400

> On Thu, Apr 27, 2006 at 02:12:09PM -0700, Caitlin Bestler (caitlinb@broadcom.com) wrote:
> > So the real issue is when there is an intelligent device that
> > uses hardware packet classification to place the packet in
> > the correct ring. We don't want to bypass packet filtering,
> > but it would be terribly wasteful to reclassify the packet.
> > Intelligent NICs will have packet classification capabilities
> > to support RDMA and iSCSI. Those capabilities should be available
> > to benefit SOCK_STREAM and SOCK_DGRAM users as well without it
> > being a choice of either turning all stack control over to
> > the NIC or ignorign all NIC capabilities beyound pretending
> > to be a dumb Ethernet NIC.
> 
> Btw, how is it supposed to work without header split capabale hardware?

I do not see header splitting as a requirement, let the raw
headers sit in the user queue and provide an offset to the data.
All of this page alignment stuff is unnecessary complexity.

I know you think applications are too dumb to be expected to handle
these kinds of things, but how many apps do you expect to convert over
to these new interfaces?

The ones that matter will, and great care will be made by the
programmer who does this.
