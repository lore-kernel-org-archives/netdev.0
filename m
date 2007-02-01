From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 hangs
Date: Thu, 1 Feb 2007 11:05:52 -0800
Message-ID: <20070201110552.5bf52c8f@localhost>
References: <20070201185532.GL13130@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:57192 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422936AbXBATJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 14:09:15 -0500
In-Reply-To: <20070201185532.GL13130@cip.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Feb 2007 19:55:32 +0100
Thomas Glanzmann <thomas@glanzmann.de> wrote:

> Hello,
> I have a sky2 network card in my intel mac mini. It stops working when I
> do havy network load like watching a divx over http/sshfs. However if I
> remove the driver module and load it again it works and even the tcp
> connection doesn't get shutdown. I automated the above procedure using
> a userland watchdog which basically does the same thing and is written
> entirely by me, because the traditional watchdog wasn't that reliable
> and did a lot of false positives:
> 
>         * Look every ten seconds if my default router is pingable (3
>           pings, one has to get back).
>                 If it isn't the case I call network_fix script (it calls the
>                 script only once after a ping gets lost. To run the script again at least one
>                 ping has to arrive again)
> 
>                 (mini) [~] cat /usr/local/sbin/fix_network
>                 #!/bin/bash
> 
>                 export PATH=/bin:/usr/bin:/usr/sbin:/sbin
> 
>                 rmmod sky2
>                 modprobe sky2
>                 ifdown eth0
>                 ifup eth0
> 
>                 If after that no ping is received from the default
>                 router for another 90 seconds I tell init to reboot and
>                 stop feeding the kernel software watchdog.
> 
>         * My watchdog also checks if sshd process is running. If it is
>           down for more than 100 seconds it reboots the machine, too.
> 
> Jan 27 22:35:35 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
> Jan 27 22:35:35 mini watchdog-tg[4146]: Running fix_network script.
> Jan 27 22:38:46 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
> Jan 27 22:38:46 mini watchdog-tg[4146]: Running fix_network script.
> Jan 27 22:44:17 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
> Jan 27 22:44:17 mini watchdog-tg[4146]: Running fix_network script.
> Jan 29 12:00:13 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
> Jan 29 12:00:13 mini watchdog-tg[4146]: Running fix_network script.
> Jan 29 19:18:59 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
> Jan 29 19:18:59 mini watchdog-tg[4146]: Running fix_network script.
> Jan 31 15:56:29 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
> Jan 31 15:56:29 mini watchdog-tg[4146]: Running fix_network script.
> Feb  1 08:56:57 mini watchdog-tg[4146]: No PONG received from 192.168.0.3 (failure 1 of 10)
> Feb  1 08:56:57 mini watchdog-tg[4146]: Running fix_network script.
> 
> I have a question to this: I wonder why the Linux Kernel (no longer?)
> increments the use counter of an ethernet driver (I saw it on sky2 and
> e1000) when the interface is up, running and configured? I can unload
> the sky2 driver without doing a 'ifconfig eth0 down' beforehand. Could
> somone provide me with background on this fact?

It was intentional in 2.6 to allow interfaces to be hot-removed.
Remember with Internet protocols there is no hard binding (normally)
between address and device and connections should not go down
if link fails.

> 
> With that everything works. If somone is interested in my userland
> watchdog, just send me an E-Mail.

Hopefully, it won't be necessary for long.
