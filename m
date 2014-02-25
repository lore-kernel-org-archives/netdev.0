From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 net-next 2/2] tcp: switch rtt estimations to usec
 resolution
Date: Tue, 25 Feb 2014 10:17:07 -0800
Message-ID: <1393352227.2316.144.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <CADVnQymGQ6V_28MTu02Yo7XjQz5OvmkbW3ozUvovhoz8g0rp=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>, Larry Brakmo <brakmo@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:41400 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526AbaBYSRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 13:17:09 -0500
Received: by mail-pa0-f47.google.com with SMTP id kp14so8431874pab.34
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 10:17:08 -0800 (PST)
In-Reply-To: <CADVnQymGQ6V_28MTu02Yo7XjQz5OvmkbW3ozUvovhoz8g0rp=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-02-25 at 12:46 -0500, Neal Cardwell wrote:

> >
> > -                       ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
> > -               }
> > -       } else if (skb && rtt_update && sack_rtt >= 0 &&
> > -                  sack_rtt > (s32)(now - TCP_SKB_CB(skb)->when)) {
> > +       } else if (skb && rtt_update && sack_rtt_us >= 0 &&
> > +                  sack_rtt_us > skb_mstamp_us_delta(&now, &skb->skb_mstamp)) {
> 
> This gets rid of the (s32) cast for the result of the time
> subtraction. Is that safe?


I think it is safe, because we made sure (sack_rtt_us >= 0) is true.

If skb_mstamp_us_delta() is returning a number bigger than 0x7fffffff
(2147 seconds), I think its better to make the compare to fail.

Thanks !
