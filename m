From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Thu, 27 Feb 2014 22:14:32 -0800
Message-ID: <1393568072.26794.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87fvn3dd9i.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:55348 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbaB1GOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 01:14:34 -0500
Received: by mail-pa0-f41.google.com with SMTP id fa1so330335pad.0
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 22:14:34 -0800 (PST)
In-Reply-To: <87fvn3dd9i.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-27 at 21:20 -0800, Andi Kleen wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> >  
> > -	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt, sack_rtt);
> > +	if (first_ackt.tv64) {
> > +		ktime_t curt = ktime_get_real();
> 
> Sorry I'm late to the party. One problem is that if a system doesn't use
> TSC for some reason this will be incredibly slow (unfortunately this
> happens for various reasons). Perhaps we need a
> ktime_get_real_but_use_jiffies_if_slow() or somesuch.

Right, so I cooked this instead :

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=363ec392352e55c61ce2799c3f15f89f9429bba7

Is this OK or do you see a problem with this ?

Thanks !
