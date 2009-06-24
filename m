From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Wed, 24 Jun 2009 16:48:32 -0700
Message-ID: <1245887312.12000.543.camel@nseg_linux_HP1.broadcom.com>
References: <4A41961B.2090206@miraclelinux.com>
 <4A4257B8.2090105@hp.com>
 <1245862760.12000.507.camel@nseg_linux_HP1.broadcom.com>
 <20090624.164233.166634429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "rick.jones2@hp.com" <rick.jones2@hp.com>,
	"nooiwa@miraclelinux.com" <nooiwa@miraclelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1452 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbZFXX6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2009 19:58:37 -0400
In-Reply-To: <20090624.164233.166634429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-06-24 at 16:42 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 24 Jun 2009 09:59:20 -0700
> 
> > On Wed, 2009-06-24 at 09:43 -0700, Rick Jones wrote:
> >> Why?  Sure, there is no IP on the link, but does that mean the link is 
> >> otherwise unusable?  Is ethtool only about IP status?
> >> 
> > 
> > Once the device is closed, we no longer keep track of the link state and
> > no longer have register access to determine the link state.  So we
> > assume it is down.  In reality, it may still be up if WoL is enabled or
> > management firmware is running, but the driver can no longer keep track
> > of it.  If we have to assume one or the other, I think it is more
> > correct to assume it is down.
> 
> This is a big problem.  I misread this situation when I decided to
> apply the patch yesterday, sorry.  We're going to have to revert it.
> 
> Applications like NetworkManager decide which devices to bring up and
> attempt DHCP etc. on based upon the link status.
> 
> So if we report link down, the interface won't even be tried even if a
> cable is plugged in.
> 
> Actually I wonder, does NM bring the interface "up" before checking
> link state?  Does anyone know?
> 

I don't know about NetworkManager, but the old ifup script will bring up
the device, wait up to 5 seconds for link up, and then do DHCP.


