From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Mon, 24 Feb 2014 17:11:07 -0800
Message-ID: <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
	 <1393280025.2316.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402250056250.1941@ja.home.ssi.bg>
	 <1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140224155130.4c286cca@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:49163 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbaBYBLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 20:11:10 -0500
Received: by mail-ie0-f175.google.com with SMTP id at1so4244592iec.34
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 17:11:09 -0800 (PST)
In-Reply-To: <20140224155130.4c286cca@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-24 at 15:51 -0800, Stephen Hemminger wrote:

> 
> The original reason I kept ms resolution and added the flag was
> that accessing high resolution time is expensive for systems where
> TSC is not stable.  Google may live in a world of SMP systems with
> good X86 CPUs with working TSC, but other architectures and system
> config's may have non-working TSC.

Well, it seems we now have alternatives to ktime_get() that were
probably not yet there at the time you made this choice ?

We only want a reasonable alternative to jiffies based measures,
we do not need ultra precise and synchronized clocks.

I'll redo tests with hpet clocksource, and local_clock()

Thanks
