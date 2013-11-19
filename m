From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 19 Nov 2013 10:31:50 -0800
Message-ID: <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
	 <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
	 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
	 <20131117141940.GA18569@1wt.eu>
	 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87li0kkhzx.fsf@natisbad.org>
	 <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131119174323.GH913@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, edumazet@google.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:51102 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307Ab3KSSby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 13:31:54 -0500
Received: by mail-yh0-f54.google.com with SMTP id a41so3745043yho.13
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 10:31:53 -0800 (PST)
In-Reply-To: <20131119174323.GH913@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-19 at 18:43 +0100, Willy Tarreau wrote:

> - #define MVNETA_TX_DONE_TIMER_PERIOD 10
> + #define MVNETA_TX_DONE_TIMER_PERIOD (1000/HZ)
> 

I suggested this in a prior mail :

#define MVNETA_TX_DONE_TIMER_PERIOD 1

But apparently it was triggering strange crashes...

> This can only have any effect if you run at 250 or 1000 Hz, but not at 100
> of course. It should reduce the time to first IRQ.
