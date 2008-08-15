From: Ingo Molnar <mingo@elte.hu>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- question about NMI
	watchdog
Date: Fri, 15 Aug 2008 15:26:46 +0200
Message-ID: <20080815132646.GF30597@elte.hu>
References: <445817.22956.qm@web82101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:50153 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753764AbYHON1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 09:27:12 -0400
Content-Disposition: inline
In-Reply-To: <445817.22956.qm@web82101.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


* David Witbrodt <dawitbro@sbcglobal.net> wrote:

> Quick question: a quick browse of 'Documentation/nmi_watchdog.txt' 
> suggests that I should use "nmi_watchdog=1", since I have SMP (CPU = 
> Athlon 64 X2, with CONFIG_SMP=y).  Should I follow your suggestion 
> later, or follow the recommendation of the 'nmi_watchdog.txt' doc?

you could try both, starting with nmi_watchdog=2 - and trying 
nmi_watchdog=1 if that doesnt work. The problem with nmi_watchdog=1 is 
that it disables high-res timers. (because it has to - it piggy-backs on 
the back of a periodic timer interrupt)

you might even want to test the NMI watchdog with an intentional 
user-space hard lockup - with the attached lockupcli.c program. 
(Warning: if you run it as root it will really lock up your box hard. 
Run it from a VGA text mode console to see any console messages.)

	Ingo

--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="lockupcli.c"


main ()
{
	iopl(3);
	for (;;) asm("cli");
}


--zhXaljGHf11kAtnf--
