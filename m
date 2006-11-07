From: John Heffner <jheffner@psc.edu>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Tue, 07 Nov 2006 16:50:33 -0500
Message-ID: <4550FFA9.8040503@psc.edu>
References: <1162924354.10806.172.camel@localhost.localdomain> <20061107.124557.21592397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tim.c.chen@linux.intel.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:12996 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1753196AbWKGVvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 16:51:16 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061107.124557.21592397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> If we don't ACK every two segments, stacks which grow the congestion
> window based upon packet counting will not grow the congestion window
> properly when they are sending smaller than MSS sized segments.

The only stack I know of that does this currently is linux, and in doing 
so does not conform to the spec. ;)  Sending to a BSD receiver will 
result in the same behavior, so the "right place" to fix this is on the 
sending side.  (I know the issue of packet vs. byte counting has come up 
many times over the last 10 years or so, and many arguments have been 
made on either side... I don't mean this to be flame bait but it's clear 
what will happen in this scenario.)

One way of viewing the current situation is that linux's packet counting 
plus ABC is more conservative than byte counting -- sometimes much more 
so.  Packet counting without ABC may be more or less conservative than 
byte counting, depending on segment sizes and receiver ACK strategy. 
Without ABC, linux is vulnerable to aggressive ACKing to inflate the 
cwnd.  This is a kind of ugly state of affairs.

Unfortunately I see no clear way to reconcile these issues short of 
switching to byte counting.  Obviously this would be a big change as 
packet counting is deeply ingrained in not only the congestion control 
but also the recovery code.

   -John
