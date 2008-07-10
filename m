From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Detecting TCP loss on the receiving side?
Date: Thu, 10 Jul 2008 14:34:30 -0700
Message-ID: <1e41a3230807101434s48dc0aaic4760f64f2e78956@mail.gmail.com>
References: <4876668C.8040108@limebrokerage.com> <48766CF0.1020101@hp.com>
	 <48766EC2.2090000@limebrokerage.com>
	 <1e41a3230807101405y437dff4er443185be3228caa5@mail.gmail.com>
	 <48767D07.2000003@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "=?ISO-8859-1?Q?Dan_No=E9?=" <dnoe@limebrokerage.com>,
	netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.228]:49094 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbYGJVeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 17:34:31 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2644852wri.5
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 14:34:30 -0700 (PDT)
In-Reply-To: <48767D07.2000003@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 2:20 PM, Rick Jones <rick.jones2@hp.com> wrote:
> John Heffner wrote:
>>
>> Looking for loss at the receiver is a bit tricky.  It doesn't look
>> like struct tcp_info has enough information to do this easily.  If you
>> are able to install a custom kernel on this machine, the Web100 patch
>> would be able to gather enough information to figure it out.  The
>> basic idea would be to look for a difference between RcvNxt and
>> RcvMax.
>
> And even then it depends on the connections having multiple segments in
> flight at one time.  Although I suppose that cuts both ways and affects the
> tracing too, but perhaps not to the same extent.
>
> Dan - seeing "brokerage" in your email and worries about latency makes me
> think that your app(s) are pushing around lots of small messages - are those
> spread-out across lots of connections, or are they consolidated into a
> rather smaller number of connections?  Also, what is the magnitude of the
> latency in these latency events?


Yes, a very slow rate makes things trickier, but transmitting less
than one segment per minRTO (200 ms) seems pretty unlikely.
Otherwise, the receiver should observe reordering.

  -John
