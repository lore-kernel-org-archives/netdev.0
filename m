From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Fri, 25 Mar 2016 06:17:24 -0700
Message-ID: <1458911844.6473.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160324165047.GA7585@1wt.eu>
	 <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
	 <56F42A00.7050002@iogearbox.net>
	 <CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
	 <1458859788.6473.2.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKQ1sVPJoaaf1gRfgYPRygfMFVqk08Q0K74wn6kLHV+vy=8w1w@mail.gmail.com>
	 <CALx6S37uZah89sNgH9wuD1J+_WEhd34Z5zmrnG8Qp-AQ7Ew=Jg@mail.gmail.com>
	 <20160325052819.GA8548@1wt.eu>
	 <1458888581.6473.30.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160325085338.GB8655@1wt.eu>
	 <CAKQ1sVMpwjegwvW1vcJKq+wRwqY0XMP_SS_LWhzc=UZq5yDcoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Yann Ylavic <ylavic.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34458 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbcCYNR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 09:17:27 -0400
Received: by mail-pa0-f51.google.com with SMTP id fe3so46453661pab.1
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 06:17:27 -0700 (PDT)
In-Reply-To: <CAKQ1sVMpwjegwvW1vcJKq+wRwqY0XMP_SS_LWhzc=UZq5yDcoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-25 at 12:21 +0100, Yann Ylavic wrote:

> Not my intention, you guys know what's the better for the kernel and its APIs.
> My concern is (was) admittedly due to my own lack of knowledge of
> (e)BPF, hence how much of kernel internals I'd need to know to make
> the SO_REUSEPORT work in my case.
> 
> But sure, any of the help suggested above would make it go away, I'll
> stay tuned.

Most of the time, the BPF filter can be trivial.

If your server has a multi queue NIC with 16 queues on a 16 cpus host,
it would be natural to use 16 listeners, to properly use the NIC
features (RSS).

BPF program would be

A = QUEUE_NUMBER(skb);
RETURN A;

If you chose to have 4 listeners instead, for whatever reasons.

A = QUEUE_NUMBER(skb);
A = A & 3;
RETURN A;


You also can use 

A = CURRENT_CPU;
RETURN A;
