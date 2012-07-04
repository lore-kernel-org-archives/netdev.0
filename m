From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netem: fix rate extension and drop accounting
Date: Wed, 04 Jul 2012 07:58:08 +0200
Message-ID: <1341381488.2583.1395.camel@edumazet-glaptop>
References: <1341307524.2583.115.camel@edumazet-glaptop>
	 <1341309257.2583.153.camel@edumazet-glaptop>
	 <20120703220442.GC5064@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Mark Gordon <msg@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41681 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab2GDF6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 01:58:13 -0400
Received: by eaak11 with SMTP id k11so2747639eaa.19
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2012 22:58:11 -0700 (PDT)
In-Reply-To: <20120703220442.GC5064@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-04 at 00:04 +0200, Hagen Paul Pfeifer wrote:

> Strange, we test the patch in detail. I will take a look ...

I tried to fix the thing but lacked time yesterday.


I had to use the good old way for my tests.


DEV=eth0
tc qdisc del dev $DEV root
tc qdisc add dev $DEV root handle 30: est 1sec 4sec netem \
        delay 100ms 10ms reorder 3
tc qdisc add dev $DEV handle 40:0 parent 30:0 tbf \
        burst 5000 limit 10000 mtu 1514 rate 100kbit
tc qdisc add dev $DEV handle 50:00 parent 40:0 pfifo limit 200

fundamentally, mixing the TBF is going to be hard with "delay ..."
especially with jitter.

Same problem for reorder : since packets are put at head of queue,
they have no effect on the 'time_to_send' of packets already in queue
and netem use more bandwidth than allowed.

I'll send the patch on the double drop accounting problem because the
fix is easy enough, but fir the rate limiting, I prefer letting you work
on it if you dont mind ?

Thanks
