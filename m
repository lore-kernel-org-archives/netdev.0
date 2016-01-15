From: Teresa Remmet <t.remmet@phytec.de>
Subject: Re: phy: SMSC LAN8710/LAN8720 high load
Date: Fri, 15 Jan 2016 10:18:50 +0100
Message-ID: <1452849530.3483.30.camel@lws-tremmet.phytec.de>
References: <1452498115.7467.23.camel@lws-tremmet.phytec.de>
	 <063D6719AE5E284EB5DD2968C1650D6D1CCC42AE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Igor Plyatov <plyatov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCC42AE@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

Am Dienstag, den 12.01.2016, 11:33 +0000 schrieb David Laight:
> From: Teresa Remmet
> > Sent: 11 January 2016 07:42
> > we have noticed load issues on our AM335x boards with a LAN8710 phy while
> > cpu is idling using 4.4-rc8.
> > 
> > CPU:   0% usr   0% sys   0% nic  99% idle   0% io   0% irq   0% sirq
> > Load average: 1.21 1.16 1.00 1/84 372
> 
> The 'Load average' value is mostly meaningless.
> It includes any process/thread that is sleeping uninterruptably - even
> if the process is never woken (or is only woken for short periods).
> 
> If you have a kernel thread that you don't want affected by signals
> (exits on some request to the driver) then you end up increasing the
> 'load average'.

thank you for your explanation. But I'm still worried that waiting so
long in this function might be a problem.

When I look at the function duration of lan87xx_read_status it takes in
average about 1277869 us. When disabling the the power detect mode the
time drops down to 555.326 us.

As disabling over device tree does not work correct for lan87xx a patch
follows.

Teresa

> 
> 	David
> 
