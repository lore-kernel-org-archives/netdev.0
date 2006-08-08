From: Christophe Devriese <christophe.devriese@eth1.org>
Subject: Re: Stackable devices.
Date: Tue, 8 Aug 2006 14:03:07 +0200
Message-ID: <20060808120307.GA17547@walrus.eth1.org>
References: <44CA34D0.1070507@candelatech.com> <20060801170329.GG29208@tuxdriver.com> <44CF8D8A.5080101@candelatech.com> <200608021102.20604.Christophe.Devriese@eurid.eu> <20060802103728.0b2fa46b@dxpl.pdx.osdl.net> <44D0E5D0.6030409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth1.org ([85.158.215.1]:9160 "EHLO walrus.kotnet.org")
	by vger.kernel.org with ESMTP id S964865AbWHHLyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 07:54:14 -0400
To: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <44D0E5D0.6030409@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 02, 2006 at 10:50:08AM -0700, Ben Greear wrote:
> Currently, the bridge hook logic is something like:
> 
> if (bridge-consumed-pkt) {
> 	return
> }
> 
> // drop through to other layers
> 
> 
> There are several other hooks I'd like to see added (pktgen receive 
> processing,
> mac-vlans, etc).  Each of these hooks are logically similar to the bridge 
> hook,
> ie if it consumes the pkt, return, else, drop through to the next hook 
> untill
> we get to the regular protocol processing logic.
> 
> I would like to be able to chain layer-2 handlers, such as bridge, mac-vlan,
> pktgen such that if one consumed, you break out of the handling, else, you
> try the next handler.  The handlers can be dynamically registered and 
> inserted
> in any order, controllable by user-space and/or module load/unload.
> 
> For many of the handlers, the logic will re-insert the packet by re-calling 
> the
> netif-rx logic, so there would need to be some protection to keep loops from
> occurring that would recurse too much and overflow the stack.

I'm also a big fan of a generalized system like this. It would need to
catch both the vlan accelerated path and the normal path.

-- 
-----------------------------------------------------------------------
Christophe Devriese                                               EURiD
Network Adminstrator / Developer
christophe.devriese@eth1.org
---------------------------- http://www.eth1.org ----------------------

