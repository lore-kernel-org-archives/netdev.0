From: Mirza Krak <mirza.krak@hostmobility.com>
Subject: Re: [PATCH 1/1] can: sja1000: clear interrupts on start
Date: Wed, 11 Nov 2015 10:54:26 +0100
Message-ID: <CAJ=nTssqwtYAos67GRr8fOzsm63v_Bx+GKEWriOjbTALuzv-0g@mail.gmail.com>
References: <1447163974-24514-1-git-send-email-mirza.krak@hostmobility.com>
	<5642F6A5.5070301@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wg@grandegger.com, andri.yngvason@marel.com,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5642F6A5.5070301@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-11-11 9:04 GMT+01:00 Marc Kleine-Budde <mkl@pengutronix.de>:
> This problem occurs only an hardware, where the SJA1000 is powered
> during system suspend?

Correct, and the controller is in UP state.


> Doesn't the SJA1000 trigger an interrupt that is detected after
> resuming? You add the fix to the open() function, which is triggered
> during $(ifconfig up), how is related to suspend/resume? Does the
> network layer call $(ifconfig down) during shutdown?

It does not trigger another interrupt.

In our tests we have seen that IE and EPI flags are set in the IR
registered when we resume the system. If we do not clear these two
flags it does not produce any other interrupts. Setting the controller
in to reset mode does not clear the IE and EPI flags, I can understand
that IE flag is not cleared as this is stated in the data-sheet, can
not explain why EPI flag is not cleared though as data-sheet states 0
(reset) for both hardware reset and SETTING MOD.0 BY SOFTWARE (which
is the reset-mode)

Reason I put it in open() is so at least a DOWN/UP procedure returns
the controller to an operating state. Also if we do an UP we should
clear any earlier states that might exist in the registers like we do
with error counters and error code capture.

Network layer does not call $(ifconfig down) during shutdown.

> There isn't any suspend/resume code in the sja1000 driver, for me it
> seems that we should add resume code that handles this problem.

Yes, resume code should be implemented to handle this and other
problems (receive data). But still a DOWN/UP procedure should clear
any previous state that could exist in the controller registers.

--=20
Med V=C3=A4nliga H=C3=A4lsningar / Best Regards

*******************************************************************
Mirza Krak
Host Mobility AB
mirza.krak@hostmobility.com
Anders Personsgatan 12, 416 64 G=C3=B6teborg
Sweden
http://www.hostmobility.com
Direct: +46 31 31 32 704
Phone: +46 31 31 32 700
=46ax: +46 31 80 67 51
Mobile: +46 730 28 06 22
*******************************************************************
