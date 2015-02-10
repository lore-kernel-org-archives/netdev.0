From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel sends ICMP unreachable for GRE packets even if there is
 a listening socket
Date: Tue, 10 Feb 2015 08:09:56 -0800
Message-ID: <1423584596.28434.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150210152410.GA9225@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:40061 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbBJQKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 11:10:00 -0500
Received: by pdev10 with SMTP id v10so22615803pde.7
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 08:10:00 -0800 (PST)
In-Reply-To: <20150210152410.GA9225@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-10 at 16:24 +0100, Steinar H. Gunderson wrote:
> [Resent from Bugzilla]
> 
> Hi,
> 
> I have a userspace GRE listener, which opens a raw socket (error handling removed):
> 
>         int gresock = socket(AF_INET6, SOCK_RAW, IPPROTO_GRE);
>         bind(gresock, (sockaddr *)&my_addr, sizeof(my_addr));
> 
> and then select()s and recvfrom()s on it, as well as sendto().
> 
> This works great. I can send and receive GRE packets. However, Linux _also_
> sends ICMPv6 unreachables when the other end sends to me. I assume this is
> because I don't have a corresponding kernel GRE tunnel interface. (I don't use
> the kernel GRE because I want, among others, stronger reordering functionality
> and possibly error correction, which is not in any standard.)
> 
> Can this be suppressed when I have such a socket giong? ip6tables -A OUTPUT can
> stop them, but it seems very hacky and kludgy.

Thats because you loaded ip6_gre maybe ?
