From: Elvis Pranskevichus <el@prans.net>
Subject: Re: sky2: eth0: hung mac 7:69 fifo 0 (165:176)
Date: Sat, 24 Nov 2007 21:32:49 -0500
Message-ID: <E1Iw7Ig-0000zL-6Z@asgard.prans.org>
References: <873av03c0f.fsf@burly.wgtn.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
To: Paul Collins <paul@burly.ondioline.org>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.prans.org ([64.79.206.200]:46216 "EHLO mail.prans.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbXKYDJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Nov 2007 22:09:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Collins wrote:

> Hi Stephen,
> 
> Running amd64 kernel built from 2ffbb8377c7a0713baf6644e285adc27a5654582
> after about three days of uptime, this morning I found the network dead
> and the following in dmesg:
> 
>   sky2 eth0: hung mac 7:69 fifo 0 (165:176)
>   sky2 eth0: receiver hang detected
>   sky2 eth0: disabling interface
>   NETDEV WATCHDOG: eth0: transmit timed out
>   sky2 eth0: tx timeout
>   sky2 eth0: transmit ring 26 .. 26 report=26 done=26
>   NETDEV WATCHDOG: eth0: transmit timed out
>   sky2 eth0: tx timeout
>   sky2 eth0: transmit ring 26 .. 26 report=26 done=26
> 
> The watchdog had been blorping for about three hours when I discovered
> it and rebooted the machine.
> 

Hello,

I have exactly the same problem with my 88E8053 on 2.6.24-rc3 here. While
there have always been issues with sky2 on that particular board, now the
situation is worse than ever. Netdev watchdog goes into an endless loop
reporting timeouts and the whole machine goes down to the point that I'm
forced to reset (not even SysRq works).

Here's the snippet from the log:

sky2 eth0: hung mac 123:3 fifo 194 (150:144)
sky2 eth0: receiver hang detected
sky2 eth0: disabling interface
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 178 .. 188 report=178 done=178
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 178 .. 188 report=178 done=178
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 178 .. 188 report=178 done=178
NETDEV WATCHDOG: eth0: transmit timed out

The board is identical to Paul's.

While mac hangs were common in 2.6.23 and earlier, it was possible to
recover the interface (either automatically, or by manual rmmod/modprobe). 
I can't reliably reproduce the issue, but it consistently comes up a couple
of times a day during high network load.

Any hints, patches are highly appreciated. 

Thanks,

--
Elvis

