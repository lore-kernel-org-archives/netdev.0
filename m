From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [RFC PATCH] smsc911x: Ignore error return from
 device_get_phy_mode()
Date: Wed, 26 Aug 2015 14:44:53 -0500
Message-ID: <55DE1735.3070106@arm.com>
References: <1440614948-27428-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tony@atomide.com" <tony@atomide.com>
To: Guenter Roeck <linux@roeck-us.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([146.101.78.143]:14773 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752306AbbHZTo6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 15:44:58 -0400
In-Reply-To: <1440614948-27428-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2015 01:49 PM, Guenter Roeck wrote:
> Check the return value from device_property_read_u32() to see if there
> is a suitable firmware interface to read the data, and abort if not.
> The function should return -ENXIO in that case; however, it returns
> -ENODATA. Check for both.
>
> Fixes: 62ee783bf1f8 ("smsc911x: Fix crash seen if neither ACPI nor OF is configured or used")
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> Needs testing. RFC because I am not sure if the -ENODATA check is acceptable.

I'm not really sure about it myself. I can think of cases where it might 
cause problems. That said it does work in an ACPI environment with or 
without the _DSD block. If the DSD/property isn't set, obviously the 
device doesn't configure (but it doesn't crash either) so that is good 
and an overall improvement for ACPI.

Also, I personally might have hoisted the reg-io-width ahead of the 
device_get_phy_mode() and removed the phy checks, but I don't imagine 
there is much functional difference at this point.

Tested-by: Jeremy Linton <jeremy.linton@arm.com>
