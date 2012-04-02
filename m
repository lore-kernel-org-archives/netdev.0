From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 1/2] net: ethtool: Add capability to retrieve
 plug-in module EEPROM
Date: Mon, 2 Apr 2012 19:14:38 +0100
Message-ID: <1333390478.2623.44.camel@bwh-desktop.uk.solarflarecom.com>
References: <4F71FE0A.3060203@solarflare.com>
	 <1333389160.2623.30.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bruce.w.allan@intel.com>,
	<mirq-linux@rere.qmqm.pl>, <decot@google.com>,
	<amit.salecha@qlogic.com>, <alexander.h.duyck@intel.com>,
	<davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Stuart Hodgson <smhodgson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53655 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752329Ab2DBSOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 14:14:42 -0400
In-Reply-To: <1333389160.2623.30.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-02 at 18:52 +0100, Ben Hutchings wrote:
[...]
> > +    ret = ops->get_module_eeprom(dev, &eeprom, data);
> > +    if (ret)
> > +        goto out;
> > +
> > +
> > +    if (copy_to_user(userbuf, data, eeprom.len)) {
> > +        ret = -EFAULT;
> > +        goto out;
> > +    }
> > +
> > +    if (copy_to_user(useraddr, &eeprom, sizeof(eeprom)))
> > +        ret = -EFAULT;
> [...]
> 
> I think you can drop this last copy as there's no information to return
> in the eeprom structure itself.
[...]

This is not the case because we need to cover short reads.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
