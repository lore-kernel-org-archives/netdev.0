From: Mark Huth <mhuth@mvista.com>
Subject: Question:  Virtual device error return is mangled
Date: Thu, 15 Jun 2006 16:33:30 -0700
Message-ID: <4491EE4A.8060001@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from homer.mvista.com ([63.81.120.158]:3243 "EHLO
	gateway-1237.mvista.com") by vger.kernel.org with ESMTP
	id S1750749AbWFOXVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 19:21:48 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Why does net/core/dev.c: dev_queue_transmit not pass back the actual 
status from hard_start_xmit in the case of a virtual device, and why is 
an error return considered a critical kernel error?

ie why:

          if (!dev->hard_start_xmit(skb, dev)) {
             ...
    rc = -ENETDOWN;
             ...
    return rc;


instead of :
          if (!rc = dev->hard_start_xmit(skb, dev)) {
             ...

             ...
    return rc;

In the case of a real device, a qdisc error gets returned up the stack, 
while in the case of say a bonding device enslaving the real device and 
encountering the same error, success gets returned up the stack.  The 
various virtual devices seem to return success whatever happens, but it 
seems like this behavior is chosen due to the fact that the real status 
cannot be passed back, even if the virtural device manages the skb ref 
count correctly, as dev_queue_transmit will turn it into -ENETDOWN.

Thanks,
Mark Huth
