From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] netem: fix rate extension and drop accounting
Date: Tue, 17 Jul 2012 01:26:01 +0200
Message-ID: <20120716232600.GI3415@nuttenaction>
References: <1341307524.2583.115.camel@edumazet-glaptop>
 <CAPVr9VP7DniPZj4vZi_myJWfL5JLYKYTXXtrXcKHo9LjEQzjYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Andreas Terzis <aterzis@google.com>
To: Mark Gordon <msg@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:58534 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750932Ab2GPX0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 19:26:10 -0400
Content-Disposition: inline
In-Reply-To: <CAPVr9VP7DniPZj4vZi_myJWfL5JLYKYTXXtrXcKHo9LjEQzjYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry Eric for the delay! I am a little bit under project pressure. But I will
test patches where I can.

* Mark Gordon | 2012-07-16 15:15:07 [-0700]:

>Sorry for the late reply on this.  I'm still pretty unsure about the math
>we're doing on
>
>delay -= netem_skb_cb(skb_peek(list))->time_to_send - now;
>
>First, shouldn't it be skb_peek_tail(list)?  Even if you do that the math

The delta is between now and when the _next_ packet is to send. New packets
are enqueued on the tail.

>doesn't really seem to work out.  In my mind there ought to be at least one
>more non-linearity.  The code before/after this patch does not work as I
>would expect and seems to have fairly random effects on the bandwidth and
>that the below patch does work for me.  Here is what I'm suggesting
>(relative to the new patches)

As Eric said: there are problems in combination with a static delay. During
rate extension development we tested the raw/vanilla "rate" functionality.
The rate part works faultless[TM] - at least independet of any other
"delay-latency generator".

Hagen
