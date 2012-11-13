From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Tue, 13 Nov 2012 15:40:29 -0800
Message-ID: <1352850029.6276.52.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1352501644-8444-1-git-send-email-mchan@broadcom.com>
 <20121113.165300.1149843648625252626.davem@davemloft.net>
 <1352845788.6276.28.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20121113.181600.667479923208656972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3246 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755043Ab2KMXko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 18:40:44 -0500
In-Reply-To: <20121113.181600.667479923208656972.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-13 at 18:16 -0500, David Miller wrote: 
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Tue, 13 Nov 2012 14:29:48 -0800
> 
> > We need to have VLAN tags inserted to packets using that interface.
> > The VID is dynamically discovered by application.  How do suggest we
> > do that if we don't use 8021q?
> 
> Ok.  So what's the reason that the VLAN device isn't given a
> valid MAC address, for example why not use the SAN one?
> 

The VLAN netdev automatically gets the MAC address from the real
netdev->dev_addr.  In this case, the real netdev does not have a valid
dev_addr because the PCI function is a SAN device.  The SAN MAC is in a
different hw address list in netdev->dev_addrs.

I suppose we can just put the SAN MAC into the real netdev->dev_addr so
that the VLAN will automatically get it.  But this doesn't seem very
nice as we would be pretending to have a normal MAC address (for
networking) in this SAN device.  The networking MAC address is in a
different PCI function.
