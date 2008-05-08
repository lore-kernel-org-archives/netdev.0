From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS]: Fix arbitrary net_device-s corruptions on
 net_ns stop.
Date: Thu, 08 May 2008 01:25:04 -0700 (PDT)
Message-ID: <20080508.012504.61259522.davem@davemloft.net>
References: <4821CBE5.5090801@fr.ibm.com>
	<4821CCD3.5020502@openvz.org>
	<4821D4F3.7000307@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45211
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752201AbYEHIZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 04:25:10 -0400
In-Reply-To: <4821D4F3.7000307@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 07 May 2008 18:12:35 +0200

> Pavel Emelyanov wrote:
> >>> +		sprintf(fb_name, "dev%d", dev->ifindex);
> >> The computed interface name can not exceed IFNAMSIZ, 3 ('dev') + 10 (max 
> >> int) + 1 ('\0'). In this case there is no risk to corrupt the stack but 
> >> may be it is more secure to change that to snprintf(fb_name, IFNAMSIZ, 
> >> "dev%d", dev->ifindex), just in case, no ?
> > 
> > But you have just noticed, that "there is no risk to corrupt the stack"!
> > What else can be "more secure" then :) ?
> 
> Just in case, for example, someone changes 'dev' by 'virtdev' or 
> something else.

I've applied Pavel's patch, but I changed it to use snprintf() to
address Daniel's concerns.

And this matches the way this is done in the rest of this file too :-)

Thanks.
