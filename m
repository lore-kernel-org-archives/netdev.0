From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] netem: fix rate extension and drop accounting
Date: Wed, 4 Jul 2012 18:51:32 +0200
Message-ID: <20120704165132.GA3455@nuttenaction>
References: <1341307524.2583.115.camel@edumazet-glaptop>
 <1341309257.2583.153.camel@edumazet-glaptop>
 <20120703220442.GC5064@nuttenaction>
 <1341381488.2583.1395.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Mark Gordon <msg@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52798 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751755Ab2GDQve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 12:51:34 -0400
Content-Disposition: inline
In-Reply-To: <1341381488.2583.1395.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2012-07-04 07:58:08 [+0200]:


>DEV=eth0
>tc qdisc del dev $DEV root
>tc qdisc add dev $DEV root handle 30: est 1sec 4sec netem \
>        delay 100ms 10ms reorder 3
>tc qdisc add dev $DEV handle 40:0 parent 30:0 tbf \
>        burst 5000 limit 10000 mtu 1514 rate 100kbit
>tc qdisc add dev $DEV handle 50:00 parent 40:0 pfifo limit 200
>
>fundamentally, mixing the TBF is going to be hard with "delay ..."
>especially with jitter.
>
>Same problem for reorder : since packets are put at head of queue,
>they have no effect on the 'time_to_send' of packets already in queue
>and netem use more bandwidth than allowed.
>
>I'll send the patch on the double drop accounting problem because the
>fix is easy enough, but fir the rate limiting, I prefer letting you work
>on it if you dont mind ?

OK, I will work on it tomorrow! But Eric, keep in mind that this accumulative
behavior is intended: think about a hypothetical satellite link with a
bandwidth (rate) of 1000 byte/s. If you send three 1000 byte consecutively
packets. The first packet is delayed for 1 second, the second then is
transmitted after 2 seconds, the third after three seconds and so on. So
_this_ accumulative behavior is correct. Anyway, I will look at this tomorrow!

Thanks Eric!

PS: one last question: what do you want to test? TBF and netem rate at the
same time looks, mmhh, special ... ;-) I ask myself what link exhibit this
characteristic?
