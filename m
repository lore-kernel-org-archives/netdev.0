From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Fri, 9 Nov 2012 16:25:22 -0800
Message-ID: <1352507122.6276.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1352501644-8444-1-git-send-email-mchan@broadcom.com>
 <1352502165.3159.21.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3488 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581Ab2KJAZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2012 19:25:43 -0500
In-Reply-To: <1352502165.3159.21.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 23:02 +0000, Ben Hutchings wrote:
> > Some bnx2x multi-function devices are configured for FCoE only in
> > a PCI function and only has a SAN MAC address.  The current code
> > will fail ->ndo_validate_addr() when a VLAN device is brought up
> > over such a device.
> > 
> > Check the real device's dev_addrs[] for a valid SAN MAC address
> > when validating the MAC address if the regular MAC address is not
> > valid.
> 
> So the VLAN device's own address is being completely ignored?

No, it is not being ignored.  We validate the VLAN's regular MAC address
first.  If it is invalid, check further to see if the real device has a
SAN MAC address.
