From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v6 net-next 1/2] net: add skb_mstamp infrastructure
Date: Tue, 25 Feb 2014 04:21:17 -0800
Message-ID: <1393330877.2316.131.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <1393309324.2316.119.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6CA6D1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:52781 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbaBYMVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 07:21:19 -0500
Received: by mail-pd0-f180.google.com with SMTP id y10so2071467pdj.25
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 04:21:19 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CA6D1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-02-25 at 09:51 +0000, David Laight wrote:

> 
> Do you need the union here?
> If you don't attempt to convert the value to a u64 then code
> is less likely to process it incorrectly.
> 

Check the second patch, it uses :

	first_ackt.v64 = 0;
...
	last_ackt = skb->skb_mstamp;
	if (!first_ackt.v64)
		first_ackt = last_ackt;

...

	skb_mstamp_get(&now);
	if (first_ackt.v64) {
        	seq_rtt_us = skb_mstamp_us_delta(&now, &first_ackt);
        	ca_seq_rtt_us = skb_mstamp_us_delta(&now, &last_ackt);
	}


Without the union, it would be more expensive on 64bit arches,
or relying on the compiler to be smart enough.

> Most modern ABI pass/return short structures in registers,
> so the actual code should be similar if you return the struct
> by value.

I am well aware of this, but this is a matter of taste, and I prefer
this more traditional way.
