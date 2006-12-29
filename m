From: Roger While <simrw@sim-basis.de>
Subject: Re. Please pull 'upstream' branch of wireless-2.6
Date: Fri, 29 Dec 2006 11:28:10 +0100
Message-ID: <6.1.1.1.2.20061229110738.02b325c8@192.168.6.12>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: linville@tuxdriver.com, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout04.sul.t-online.com ([194.25.134.18]:51891 "EHLO
	mailout04.sul.t-online.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754144AbWL2NtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 08:49:05 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > Roy Marples (1):
> >       prism54: set carrier flags correctly
>
>Why is this not #upstream-fixes material?  What's the impact?

Actually, I think the patch is incorrect.
At best it is insufficient and at worst it
stops the driver working correctly.

I can't see why we do carrier_off after start_queue in the open.
Other drivers (eg. ipw2100) do carrier_on.

We should also look at other places where eg. stop_queue
is called and do a carrier_off eg. the close routine.
(Amongst others)

Also according to Documentation/networking/operstates.txt
(netif_carrier_on/off) -
"It is guaranteed that only the driver has write access,
  however, if different layers of the driver manipulate the same flag,
  the driver has to provide the synchronisation needed."

The trap routine in isl_ioctl.c however is lockless.
Assuming that the doc is correct, I would have thought
that putting carrier_on/off here is buggy or ?

Roger While


