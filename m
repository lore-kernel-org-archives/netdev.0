From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: Re: [PATCH] [RFC] New driver "sfc" for Solarstorm SFC4000 controller
Date: Thu, 29 Nov 2007 16:27:41 +0000
Message-ID: <474EE87D.6010702@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	bhutchings@solarflare.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nextweb.net ([216.237.6.30]:40707 "EHLO
	smtp.covadwireless.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760370AbXK2Q1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 11:27:48 -0500
Received: from mail.nextweb.net (mail.nextweb.net [216.237.6.33])
	by smtp.covadwireless.net (Spam Firewall) with ESMTP id 105D7193B59F
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 08:27:46 -0800 (PST)
Received: from mail.nextweb.net (mail.nextweb.net [216.237.6.33]) by smtp.covadwireless.net with ESMTP id Dk7N5YP6unxVOAIM for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 08:27:46 -0800 (PST)
Received: from unknown (HELO mail.solarflare.com) ([216.237.3.213])
          (envelope-sender <rstonehouse@solarflare.com>)
          by mail.nextweb.net (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 29 Nov 2007 16:27:45 -0000
Received: from OCEX01.SolarFlarecom.com (unknown [10.20.40.32])
	by mail.solarflare.com (Postfix) with ESMTP id 65FDF4492E
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 08:27:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 23 Nov 2007 17:08:15 +0000
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>   
>> 1. When we enable NAPI polling, we need to set __LINK_STATE_START in
>>    the net device used for NAPI.  This bit is commented as private in
>>    netdevice.h, but e1000 also does this.  Is this incorrect?
>>     
> Why are you using it directly?
>   
It seems this line is historic and we can remove it.

> The driver is pretty big (28K loc), and non trivial to get a good review.

We are aware that it appears to be a large amount of code.

The driver does support many types of PHY (10Gbase-T, XFP, CX4) on five
different 10G reference designs and one 1G NIC ref design.

There is also support for two generations of controller silicon, full
ethtool support, start of day self-tests and an mtd driver for putting
PXE images into flash.

Perhaps we could help making it more reviewable by suggesting some sets
of files that can be reviewed together that represent different parts of
the functionality. The main functionality is contained in efx.c, rx.c,
tx.c and falcon.c if that helps.


> Minor note:
> * use u8 not uint8_t (etc.)
> * gone overboard with docbook style comments, they are only needed
>   on external API's.
> * Please use dev_err() rather than reinventing own message macros.

OK - we will look at addressing these as well as checkpatch violations
and resubmit a patch shortly.

> * why are you exporting symbol's?
>   
We need a small API so that other drivers can use parts of the hardware
after the main driver has performed initialisation.

One example is the mtd driver to access the flash. Another example is an
accelerated driver for Xen that Solarflare is in the process of
submitting.

Regards

-- 
Rob Stonehouse
