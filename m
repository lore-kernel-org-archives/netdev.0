From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Wed, 8 Oct 2008 16:34:30 -0300
Message-ID: <48ed0b51.0913c00a.7715.4aa7@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
	<Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
	<48e5364d.0603c00a.6e25.fffff993@mx.google.com>
	<Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
	<48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com>
	<alpine.LFD.2.00.0810052008131.3398@apollo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:14447 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbYJHTeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 15:34:44 -0400
Received: by rv-out-0506.google.com with SMTP id k40so4376736rvb.1
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 12:34:43 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.0810052008131.3398@apollo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 5 Oct 2008 20:09:22 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> The cat /debug/tracing/tracing_enabled == 1 might be just a user space
> interface thingy.
> 
> Thanks,

	Thomas, Ilpo etc, I got a trace exactly after the patch
provided by Thomas detected the stall:

http://www.abusar.org/ftrace/trace-final.txt.bz2

	Thomas, since you didn't reply to the previous messages, I
assume the previous traces were invalid. But could you please check
this one?

	It would be wise to search for "monit" in the trace, since
monit activated the script "stop-tracing.sh" which stops the trace and
dump the trace output to the file. So what probably interest you is
what comes *before* "monit".

	"monit" appears for the first time in line 16921.

	To make it more clear, I configured monit with the following:

check file syslog with path /var/adm/messages
	if match "Tracer stopped" then exec "/home/fraga/stop-tracing.sh"

	And the stop-tracing.sh script is just that:

#!/bin/sh
/usr/local/bin/echo 0 > /debug/tracing/tracing_enabled
/usr/local/bin/cat /debug/tracing/trace > /home/fraga/trace.txt

	So I expect that this trace is right now.

	If monit was too slow in detecting the "Tracer stopped" log entry, I'll 
use a Perl script which is faster.

	Thanks, I wait for your reply.

	Ps: flood_mail.pl is just a perl script I use to prevent people from flooding
my smtp server with mail.

	Ps2: I just don't know if it would be better to stop the tracing *before*
dump the trace or it would be better to dump the trace without stopping it... I noticed
that even the "echo" I use to stop the tracing, generated a lot of useless tracing information.

-- 
