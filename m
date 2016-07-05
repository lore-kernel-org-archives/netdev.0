From: Mason <slash.tmp@free.fr>
Subject: Re: WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:155
 inet_sock_destruct+0x1c4/0x1dc
Date: Tue, 5 Jul 2016 17:56:43 +0200
Message-ID: <577BD8BB.7060306@free.fr>
References: <577BB72E.3020904@free.fr> <577BC94A.4060204@free.fr>
 <577BD201.2040202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Sebastian Frias <sf84@laposte.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	linux-pm <linux-pm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <577BD201.2040202@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/2016 17:28, Florian Fainelli wrote:

> nb8800.c does not currently show suspend/resume hooks implemented, are
> you positive that when you suspend, you properly tear down all HW, stop
> transmit queues, etc. and do the opposite upon resumption?

I am currently testing the error path for my suspend routine.
Firmware is, in fact, denying the suspend request, and immediately
returns control to Linux, without having powered anything down.

I expected not having to save any context in that situation.
Am I mistaken?

You mention "stop transmit queues". Can you say more about this?

> Is your system clocksource also correctly saved/restored, or if you go
> through a firmware in-between could it be changing the counter values
> and make Linux think that more time as elapsed than it really happened?

Thanks for pointing this out, I was not aware I was supposed to save
and restore the tick counter on suspend/resume. (This is not an issue
in this specific situation, as the platform is NOT suspended.)

However, your remark has brought some more confusion to my mind.
Linux is expecting time to stand still when it suspends?
What if the tick counter is in an always-on power domain, and other
processors depend on the counter? I can't just overwrite the reg
when Linux resumes...

Regards.
