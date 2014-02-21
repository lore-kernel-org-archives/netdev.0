From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [net-next 3/3] ixgbe: Check config reads for removal
Date: Fri, 21 Feb 2014 04:11:28 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73159251@ORSMSX101.amr.corp.intel.com>
References: <1392871521-7731-1-git-send-email-aaron.f.brown@intel.com>
	<1392871521-7731-4-git-send-email-aaron.f.brown@intel.com>
 <20140220.133221.371192280746136183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42028 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737AbaBUELa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 23:11:30 -0500
In-Reply-To: <20140220.133221.371192280746136183.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, February 20, 2014 10:32 AM
> To: Brown, Aaron F
> Cc: Rustad, Mark D; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com
> Subject: Re: [net-next 3/3] ixgbe: Check config reads for removal
> 
> From: Aaron Brown <aaron.f.brown@intel.com>
> Date: Wed, 19 Feb 2014 20:45:21 -0800
> 
> > -	if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO))
> > +	if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO) ||
> > +		ixgbe_removed(hw->hw_addr))
> >  		goto out;
> 
> This is not indented correctly, the second line of the if() statement
> should start at the first column after the openning parenthesis of the
> top-level if() statement.

Thanks Dave,

Turns out we noticed another minor issue in this as well, but significant enough to warrant running it through test again, so I'll resubmit the series again once it gets through the process.

> 
> > +	if (*value == IXGBE_FAILED_READ_CFG_WORD &&
> > +	    ixgbe_check_cfg_remove(&adapter->hw, parent_dev))
> > +		return -1;
> 
> Just as you correctly did here.
