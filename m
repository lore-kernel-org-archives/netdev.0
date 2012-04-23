From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [net-next PATCH] net: dcb: add CEE notify calls
Date: Mon, 23 Apr 2012 20:00:01 +0300
Message-ID: <1335200401.15423.18.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <20120420194923.8103.54825.stgit@jf-dev1-dcblab>
 <1335185512.15423.10.camel@lb-tlvb-shmulik.il.broadcom.com>
 <4F955AE8.6040802@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	amirv@dev.mellanox.co.il
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2794 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812Ab2DWO5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2012 10:57:35 -0400
In-Reply-To: <4F955AE8.6040802@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> No. We want all the firmware agents and host based agents to look the
> same from the application. The situation you described is exactly the
> same for user space as in firmware. The DCBx state machine starts and may
> call dcbnl_setxxx with initial (local) values. At some later point these
> may change (possibly because of negotiation with a peer) and we need to
> call dcbnl_setxxx again.
> 
> I don't see how this complicates any user mode code? Presumably the agent
> is listening to DCBx events because it really wants to know the current
> state of DCBx. It seems to me skipping notifications will actually cause
> more issues this results in the hardware being in some state that did not
> trigger any events and the agent will now be out of sync. This is the
> problem I am trying to solve.
> 
> btw with this patch we can remove the notify calls in bnx2x.
> 
> .John
> 
OK, I see.
>From a user mode application monitoring the netlink notification you get
successive updates each indicating the current valid negotiated
parameters (and HW state) and that's fine.
However I don't see how you can remove the notification call form the
bnx2x. When the FW DCBx agent decides to change the negotiated
parameters (perhaps in response to a peer request), it alerts the driver
which configures the HW and then needs to somehow notify the user about
the newly negotiated parameters.

Shmulik  
