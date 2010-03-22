From: "Goff, Thomas" <Thomas.Goff@boeing.com>
Subject: RE: [PATCH] netdev: don't always reset iflink when registering
Date: Mon, 22 Mar 2010 12:06:46 -0700
Message-ID: <6AFD35BEDB60334C9A31FD694E13EF0D22676C2244@XCH-NW-18V.nw.nos.boeing.com>
References: <20100320013917.GB13239@boeing.com> <4BA7AC13.3080408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:56673 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab0CVTHA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 15:07:00 -0400
In-Reply-To: <4BA7AC13.3080408@trash.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <mailto:kaber@trash.net>
Sent: Monday, March 22, 2010 10:43 AM
> 
> Tom Goff wrote:
> > Bound tunnel devices set their iflink to the ifindex of the 
> underlying
> > network interface when created.  It shouldn't be reset by the
> > registration process.
> >   
> 
> Which ones exactly? Usually they do this in ->setup() or later on.

I observed the issue with a bound gre tunnel where:

	ipgre_newlink()
		...
		ipgre_tunnel_bind_dev()	/* set dev->iflink */
		...
		register_netdevice()	/* reset dev->iflink */

There's a similar pattern in ipv6/sit.c:

	ipip6_tunnel_locate()
		...
		ipip6_tunnel_init()
			...
			ipip6_tunnel_bind_dev()	/* set dev->iflink */
		...
		register_netdevice()		/* reset dev->iflink */

So maybe it makes more sense to change these if that's more consistent
with other cases.

Thanks for looking at this and the tc stuff.

  Tom
