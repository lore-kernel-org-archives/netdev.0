From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic TPROXY , vanilla 4.7.1
Date: Wed, 17 Aug 2016 08:42:05 -0700
Message-ID: <1471448525.29842.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <627722c51d9ce454dfaf1a79519ceb59@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35461 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbcHQPmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 11:42:08 -0400
Received: by mail-pf0-f173.google.com with SMTP id x72so38674209pfd.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 08:42:08 -0700 (PDT)
In-Reply-To: <627722c51d9ce454dfaf1a79519ceb59@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-17 at 17:31 +0300, Denys Fedoryshchenko wrote:
> Hi!
> 
> Tried to run squid on latest kernel, and hit a panic
> Sometimes it just shows warning in dmesg (but doesnt work properly)
> [   75.701666] IPv4: Attempt to release TCP socket in state 10 
> ffff88102d430780
> [   83.866974] squid (2700) used greatest stack depth: 12912 bytes left
> [   87.506644] IPv4: Attempt to release TCP socket in state 10 
> ffff880078a48780
> [  114.704295] IPv4: Attempt to release TCP socket in state 10 
> ffff881029f8ad00
> 
> I cannot catch yet oops/panic message, netconsole not working.
> 
> After triggering warning message 3 times, i am unable to run squid 
> anymore (without reboot), and in netstat it doesnt show port running.
> 
> firewall is:
> *mangle
> -A PREROUTING -p tcp -m socket -j DIVERT
> -A PREROUTING -p tcp -m tcp --dport 80 -i eno1 -j TPROXY --on-port 3129 
> --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1
> -A DIVERT -j MARK --set-xmark 0x1/0xffffffff
> -A DIVERT -j ACCEPT
> 
> routing
> ip rule add fwmark 1 lookup 100
> ip route add local default dev eno1 table 100
> 
> 
> squid config is default with tproxy option
> http_port 3129 tproxy
> 

Hmppff... sorry for this, I will send a fix.

Thanks for the report !
