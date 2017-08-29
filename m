From: Willy Tarreau <w@1wt.eu>
Subject: Re: net.ipv4.tcp_max_syn_backlog implementation
Date: Tue, 29 Aug 2017 06:12:33 +0200
Message-ID: <20170829041233.GC28122@1wt.eu>
References: <CAMB9Wx+q9fidTnh3Tyias8KKdbRcKpoXM-ntSqjE_oW36F1W_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Harsha Chenji <cjkernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:35775 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751209AbdH2EMg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 00:12:36 -0400
Content-Disposition: inline
In-Reply-To: <CAMB9Wx+q9fidTnh3Tyias8KKdbRcKpoXM-ntSqjE_oW36F1W_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 11:47:41PM -0400, Harsha Chenji wrote:
> So I have ubuntu 12.04 x32 in a VM with syncookies turned off. I tried
> to do a syn flood (with netwox) on 3 different processes. Each of them
> returns a different value with netstat -na | grep -c RECV :
> 
> nc -l 5555 returns 16 (netcat-traditional)
> apache2 port 80 returns 256
> vsftpd on 21 returns 64.
> net.ipv4.tcp_max_syn_backlog is 512.
> 
> Why do these different processes on different ports have different
> queue lengths for incomplete connections? Where exactly in the kernel
> is this decided?

The listening socket's backlog (second argument to the listen() syscall)
is considered as well. The code path to determine whether or not to start
to send SYN cookies is far from being trivial but makes sense once you
write it down completely. I never perfectly remember it, I regularly have
to recheck when I have a doubt.

Willy
