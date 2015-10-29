From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Any-IP IPv6 support broken
Date: Thu, 29 Oct 2015 08:34:48 -0700
Message-ID: <1446132888.7476.153.camel@edumazet-glaptop2.roam.corp.google.com>
References: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gilberto Bertin <gilberto.bertin@gmail.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32870 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbbJ2Peu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 11:34:50 -0400
Received: by padhy1 with SMTP id hy1so38096994pad.0
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 08:34:49 -0700 (PDT)
In-Reply-To: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-29 at 15:00 +0000, Gilberto Bertin wrote:
> Hello,
> testing Any-IP on my machine, I noticed that it's not working with IPv6
> addresses.
> Tests are performed on a 4.1 kernel.
> 
> Steps to reproduce the bug:
> 
> 1- make sure Any-IP is working with IPv4 addresses:
> 
> # ip -4 route add local 4.4.4.0/24 dev eth0
> 
> with this command every packets with an IP in the subnet 4.4.4.0/24 will
> be delivered to the eth0 interface.
> We can test this:
> 
> $ ping 4.4.4.1 -c 1 | grep received
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> $ ping 4.4.4.50 -c 1 | grep received
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> $ ping 4.4.4.200 -c 1 | grep received
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> 
> 2- note that it's not actually working with IPv6 addresses:
> 
> # ip -6 route add local abcd:abcd:abcd:abcd::/64 dev eth0
> 
> $ ping6 -c 1 abcd:abcd:abcd:abcd::1 | grep received
> 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> $ ping6 -c 1 abcd:abcd:abcd:abcd::50 | grep received
> 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> $ ping6 -c 1 abcd:abcd:abcd:abcd::100 | grep received
> 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> 
> Since the kernel should support Any-IP with IPv6 addresses (the patch
> was submitted/accepted years ago [1]) I suspect this is a bug.
> 
> Even trying with the commands suggested by the patch [1]:
> # ip -6 rule  add from all iif eth0 lookup 200
> # ip -6 route add local default dev lo table 200
> 
> I was not able to get it working.
> 
> 
> Thank you.
> 
> [1] http://www.spinics.net/lists/netdev/msg141994.html
> 


CC Maciej
