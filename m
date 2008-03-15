From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: [2.6.24.3][net] bug: TCP 3rd handshake abnormal timeouts
Date: Sat, 15 Mar 2008 09:51:35 +0100
Message-ID: <47DB8E17.8080309@oxeva.fr>
References: <47DB28E9.4050309@oxeva.fr> <20080315065739.GL8953@1wt.eu> <20080315065849.GA11817@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.reagi.com ([195.60.188.80]:51739 "EHLO mail.reagi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410AbYCOI6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Mar 2008 04:58:24 -0400
In-Reply-To: <20080315065849.GA11817@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[corrected the netdev mailing list address]

Hi

Thanks for the netdev Cc, I didn't know where to write to the "network
guys".

By the way thanks for replying. It's hard to explain and describe a
problem when you know people will ask you hundreds of questions related
to application-level problems, or not reply because web/mysql problems
are so common and generally not related to any kernel issue.

On 03/15/2008 7:58:49 AM +0100, Willy Tarreau <w@1wt.eu> wrote:
> 
> You should carefully check the the SYN-ACK received by the client has a
> correct checksum ("cksum OK" in tcpdump output). It would be possible
> that for some reason, something on the network randomly corrupts it.

I used to use TCP offloading one time, and by the way never had a
problem with it. Besides just to be sure, I have been able to reproduce
the problem without any offload engine enabled (= not compiled into the
kernel, mainly because it seems to hang the kernel at boot in 2.6.24.3).
So I assume that is not the problem

I use wireshark to analyse my pcap files and it says the checksum is
correct on all packets.

> Also, you say you have netfilter with conntrack. Is this on the client ?
> If so, you should try disabling it to rule out any possible bug in the
> connection tracking.

I have the conntrack  on both the client and server, and unfortunately
can't disable it now on the client (I use it only for the REDIRECT
target on a precise destination address and port, not MySQL related),
however I will test today and disable it on the server, after I get some
sleep (although I think the issue is on the client).

Gabriel

