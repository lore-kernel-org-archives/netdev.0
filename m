From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Mon, 20 Apr 2009 14:13:23 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904201410430.3361@qirst.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com>
 <alpine.DEB.1.10.0904201305360.1585@qirst.com> <49ECB775.6030202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:56485 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814AbZDTSVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 14:21:13 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 41B0D82C61D
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 14:31:31 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id CCnlf25u7tul for <netdev@vger.kernel.org>;
	Mon, 20 Apr 2009 14:31:31 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7E60F82C620
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 14:31:26 -0400 (EDT)
In-Reply-To: <49ECB775.6030202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Apr 2009, Eric Dumazet wrote:

> > Sounds very good. If I just knew what you are measuring.
>
> Rephrasing my email, I was measuring latencies on the receiving machine,
> by using tcpdump and doing substraction of 'answer_time' and 'request_time'
> Thing is that timestamps dont care about hardware delays.
> (we note time when RX interrupt delivers the packet, and time right before giving frame to hardware)
>
>
> 21:04:23.780421 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, length 300   (request)
> 21:04:23.780428 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, length 300   (answer)
>
> Here, [21:04:23.780428 - 21:04:23.780421] = 7 us
>
> So my results are extensively published :)

But they are not comparable with my results. There could be other effects
in the system call API etc that have caused this regression. Plus tcpdump
causes additional copies of the packet to be delivered to user space.

> > CONFIG_HPET_TIMER=y
> > CONFIG_HPET_EMULATE_RTC=y
> > CONFIG_NR_CPUS=32
> > CONFIG_SCHED_SMT=y
>
> OK, I had "# CONFIG_SCHED_SMT is not set"
> I'll try with this option set

Should not be relevant since the processor has no hyperthreading.

> Are you running a 32 or 64 bits kernel ?

Test was done using a 64 bit kernel.
