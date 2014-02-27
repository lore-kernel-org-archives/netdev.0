From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7 net-next 2/2] tcp: switch rtt estimations to usec
 resolution
Date: Wed, 26 Feb 2014 18:25:46 -0800
Message-ID: <1393467946.26794.15.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393309341.2316.120.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393452168.26794.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140226170908.5f028c88@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:44807 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbaB0CZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 21:25:48 -0500
Received: by mail-pb0-f42.google.com with SMTP id rr13so1845689pbb.15
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 18:25:47 -0800 (PST)
In-Reply-To: <20140226170908.5f028c88@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-26 at 17:09 -0800, Stephen Hemminger wrote:

> 
> Since srtt is scaled by 8 and is 32 bits, This does reduce the maximum
> possible RTT to 8 minutes or so. Which is fine, just wanted it to be
> noted.

Note that I plan to remove the scaling by 8.

We also are experimenting alternatives to srtt.

Van Jacobson admits he was on drugs at the time he did it ;)

Idea would be to keep latest 3 (or 5) rtt samples, and either
get the maximum value for RTO, or the mininum values for pacing
or congestion modules. This would filter delay acks in the right way.

I'd like to instrument hystart, it seems we can do a bit better than
current situation, before the new stuff.

Thanks !
