From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [patch sungem] improved locking
Date: Wed, 13 Dec 2006 14:24:05 +1100
Message-ID: <1165980245.11914.120.camel@localhost.localdomain>
References: <5cac192f0611132328i52d6d615g28d8c493dc028621@mail.gmail.com>
	 <20061113.234456.78492515.davem@davemloft.net>
	 <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
	 <20061128.144911.55733883.davem@davemloft.net>
	 <5cac192f0611290256l7067ce21r39881486f6e21289@mail.gmail.com>
	 <5cac192f0611291437g26fefebdocdacbb0cd2aa2fdd@mail.gmail.com>
	 <1165979533.11914.114.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54367 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932528AbWLMDYN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 22:24:13 -0500
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <1165979533.11914.114.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-13 at 14:12 +1100, Benjamin Herrenschmidt wrote:
> Been hitting a raw throughput in both directions plus a few other things
> on a dual G5 and the driver didn't crash :-)
> 
> I'm seeing a problem though but I'm not sure it's related to your patch,
> I'll have to test without it.
> 
> Basically, if I use a slightly modified versio of tridge's socklib (raw
> xput test, basically, a tcp connection with one side pushing as fast as
> it can a known pattern and the other one just receiving and verifying
> the data integrity), it works fine when running only one side (either rx
> or tx, doesn't matter).
> 
> But if I start it both ways (that is both a receiver and a sender on the
> GMAC box) and the other end is a tg3 (quad g5), then I'm getting a lot
> of eth0: RX MAC fifo overflow smac[02045822 but there are other numbers
> here every now and then] errors on the sungem side.
> 
> David, could that be the pause stuff not working properly ?
> 
> The link is gigabit and the tg3 side doesn't complain about anything.

I've verified that the problem isn't related to Eric's patch and is
there without it... I suppose I just never noticed it before :-)

So far, the patch looks solid. I'll let it run overnight and will holler
if things went wrong tomorrow.

Cheers,
Ben.


