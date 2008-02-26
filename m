From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: problems with e1000 and flow control
Date: Tue, 26 Feb 2008 10:26:41 -0800
Message-ID: <47C459E1.1050803@intel.com>
References: <200802252015.49862.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6097 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882AbYBZSol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 13:44:41 -0500
In-Reply-To: <200802252015.49862.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Walter wrote:
> Hello,
> 
> it seems that e1000 enables flow-control (rx pause frames) even if the switch 
> does not advertise flow control. This seems to get a problem as (at least 
> some) switches then forward pause frames directed to the card from other 
> hosts. We think there are hosts which indeed do this in the lans of our 
> student halls.
> 
> I think flow control should be completely disabled by default if the switch 
> does not advertise it. It still can be forced with ethtool.

Are you sure that the switch actually advertises the flow control "disabled"
setting properly? Perhaps you can include the e1000 ethtool flow control settings
and dmesg output (2.6.24 will print out FC status when link comes up).

There's a lengthy argumentation including spec references in the e1000/e1000e
driver code on how FC is handled (look for "IEEE 802.3ab"). Can you take a look at
that and see what might be happening?

Changing this behaviour might give other people issues which is something we need
to be very cautious about, obviously :)

Cheers,

Auke
