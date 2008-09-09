From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 08 Sep 2008 22:17:42 -0700 (PDT)
Message-ID: <20080908.221742.02572583.davem@davemloft.net>
References: <48C59F75.6030504@redhat.com>
	<48C5A9A9.9040503@hp.com>
	<48C6052D.2080203@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751571AbYIIFRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 01:17:48 -0400
In-Reply-To: <48C6052D.2080203@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Snook <csnook@redhat.com>
Date: Tue, 09 Sep 2008 01:10:05 -0400

> This is open to debate, but there are certainly a great many apps
> doing a great deal of very important business that are subject to
> this problem to some degree.

Let's be frank and be honest that we're talking about message passing
financial service applications.

And I specifically know that the problem they run into is that the
congestion window doesn't open up because of Nagle _AND_ the fact that
congestion control is done using packet counts rather that data byte
totals.  So if you send lots of small stuff, the window doesn't open.
Nagle just makes this problem worse, rather than create it.

And we have a workaround for them, which is a combination of the
tcp_slow_start_after_idle sysctl in combination with route metrics
specifying the initial congestion window value to use.

I specifically added that sysctl for this specific situation.

Really, the situation here is well established and I highly encourage
you to take a deeper look into the actual problems being hit, and show
us some specific traces we can analyze properly if the problem is still
there.

Otherwise we're just shooting into the wind without any specifics to
work on whatsoever.
