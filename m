From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Tue, 13 Nov 2012 14:29:48 -0800
Message-ID: <1352845788.6276.28.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1352501644-8444-1-git-send-email-mchan@broadcom.com>
 <20121113.165300.1149843648625252626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3327 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754870Ab2KMW37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 17:29:59 -0500
In-Reply-To: <20121113.165300.1149843648625252626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-13 at 16:53 -0500, David Miller wrote:
> I can only assume that, in this case, this code block is triggered
> in vlan_dev_open():
> 
>         if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr)) {
>                 err = dev_uc_add(real_dev, dev->dev_addr);
>                 if (err < 0)
>                         goto out;
>         }

No, this is not triggered.  The addresses will be equal (and invalid) in
this case.  No addresses will be added.
> 
> And if so we're adding an invalid ethernet address to the underlying
> device's UC list.  Yet another terrible aspect of this situation.
> 
> The more I look into this situation the more it looks like piling crap
> on top of crap on top of crap.  It's a long depency chain of special
> cases just to get this weird setup working.
> 
> I'm sorry, I'm not making the situation even worse by applying this
> patch.  If you want to have real bypasses to allow VLAN VIDs to
> be configured on SAN devices, create a real interface for it, rather
> than hack to shreds the stuff we have already.

I don't understand.  We need to have VLAN tags inserted to packets using
that interface.  The VID is dynamically discovered by application.  How
do suggest we do that if we don't use 8021q?
> 
> 
