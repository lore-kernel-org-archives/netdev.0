From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Tue, 25 May 2010 22:52:36 -0700 (PDT)
Message-ID: <20100525.225236.226781050.davem@davemloft.net>
References: <alpine.DEB.1.00.1005252157150.27170@pokey.mtv.corp.google.com>
	<20100525220858.1071f238@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org, ycheng@google.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751443Ab0EZFw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 01:52:27 -0400
In-Reply-To: <20100525220858.1071f238@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 25 May 2010 22:08:58 -0700

> The IETF TCP maintainers already think Linux TCP allows unsafe
> operation, this will just allow more possible misuse and prove
> their argument.  Until/unless this behavior was approved by
> a wider set of research, I don't think it should be accepted at
> this time.

Yes, and two other points I'd like to add.

1) Stop pretending a network path characteristic can be made into
   an application level one, else I'll stop reading your patches.

   You can try to use smoke and mirrors to make your justification by
   saying that an application can circumvent things right now by
   openning up multiple connections.  But guess what?  If that act
   overflows a network queue, we'll pull the CWND back on all of those
   connections while their CWNDs are still small and therefore way
   before things get out of hand.

   Whereas if you set the initial window high, the CWND is wildly out
   of control before we are even started.

   And even after your patch the "abuse" ability is still there.  So
   since your patch doesn't prevent the "abuse", you really don't care
   about CWND abuse.  Instead, you simply want to pimp your feature.

2) The very last application I'd want to use something like this is a
   damn web browser.

   Maybe a program, which is extremely sophisticated, like a database
   or caching manager, that runs privileged and somehow has complete
   and constantly updated knowledge of the network topology from end
   to end.  And iff, and only iff, we only would let privileged
   applications make the setting.

Right now we only allow to do this via a route setting, exactly because:

1) It is a network path characteristic, full stop.

2) Only humans can really know what the exact end to end path
   characteristics are on a per-route basis, and given that whether it
   is safe to increase the initial CWND as a result.
