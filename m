From: Patrick McHardy <kaber@trash.net>
Subject: Re: Using netconsole and getting double prints
Date: Fri, 06 Nov 2009 17:38:20 +0100
Message-ID: <4AF450FC.3020205@trash.net>
References: <43e72e890911051654i19c18bf3nd397662ed79712c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33108 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759454AbZKFQiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 11:38:17 -0500
In-Reply-To: <43e72e890911051654i19c18bf3nd397662ed79712c4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luis R. Rodriguez wrote:
> I'm getting double prints when using netconsole. This used to happen
> to me and then I just enable debugging log level manually (dmesg -n 8)
> but now no matter what I try I always get double prints.
> 
> For example:
> 
> [   23.425448] console [netcon0] enabled
> [   23.425567] netconsole: network logging started
> [   23.425448] console [netcon0] enabled
> [   23.425567] netconsole: network logging started
> [   32.856073] eth0: no IPv6 routers present
> [   32.856073] eth0: no IPv6 routers present
> [   66.307342] kmemleak: 6 new suspected memory leaks (see
> /sys/kernel/debug/kmemleak)
> [   66.307342] kmemleak: 6 new suspected memory leaks (see
> /sys/kernel/debug/kmemleak)
> 
> Instead of dmesg -8 I'm now using ignore_loglevel as a kernel
> parameter but I still get double prints. This also happens if I use
> "debug" as a kernel parameter instead.
> 
> The netconsole is set up on the dev box as follows through an /etc/rc.local
> 
> dhclient eth0
> IP=192.168.2
> # sudo dmesg -n 8
> modprobe netconsole netconsole=@/eth0,6666@${IP}/

Without a MAC address netconsole broadcasts the messages.
So I'd guess the receiving system has multiple NICs and
receives the message multiple times.
