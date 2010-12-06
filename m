From: Brian Haley <brian.haley@hp.com>
Subject: Re: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Mon, 06 Dec 2010 11:10:24 -0500
Message-ID: <4CFD0AF0.9090809@hp.com>
References: <m17hfnlpe1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:4499 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab0LFQK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 11:10:27 -0500
In-Reply-To: <m17hfnlpe1.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2010 07:24 PM, Eric W. Biederman wrote:
> 
> In 2.6.37-rc4 ipv6 can be disabled not enabled.
> The last kernel I have tested and know this works on is 2.6.33.
> 
> To reproduce:
>    ~ # ip link set lo up
>    ~ # ping6 ::1
>    PING ::1(::1) 56 data bytes
>    64 bytes from ::1: icmp_seq=1 ttl=64 time=0.026 ms
>    ^C
>    --- ::1 ping statistics ---
>    1 packets transmitted, 1 received, 0% packet loss, time 782ms
>    rtt min/avg/max/mdev = 0.026/0.026/0.026/0.000 ms
>    ~ # echo 1 > /proc/sys/net/ipv6/conf/lo/disable_ipv6 
>    ~ # ping6 ::1
>    connect: Network is unreachable
>    ~ # echo 0 > /proc/sys/net/ipv6/conf/lo/disable_ipv6 
>    ~ # ping6 ::1
>    connect: Network is unreachable
> 
> 
> I intend to poke at this a little more but at the moment
> I am drawing a blank at what is going on.

It should just be calling addrconf_notify() with either NETDEV_UP
or NETDEV_DOWN.  Does the address not come back?  Or the route?

> I intend to keep poking at this but if anyone can figure this out
> before I do I would be greatly appreciative.

I'm pulling the latest tree now, my 2.6.32.24 system is running fine, so
it's something after that.

-Brian
