From: Willy Tarreau <w@1wt.eu>
Subject: Re: [2.6.24.3][net] bug: TCP 3rd handshake abnormal timeouts
Date: Sat, 15 Mar 2008 09:55:27 +0100
Message-ID: <20080315085527.GA6239@1wt.eu>
References: <47DB28E9.4050309@oxeva.fr> <20080315065739.GL8953@1wt.eu> <20080315065849.GA11817@1wt.eu> <47DB8D1C.7020006@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2465 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114AbYCOIza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Mar 2008 04:55:30 -0400
Content-Disposition: inline
In-Reply-To: <47DB8D1C.7020006@oxeva.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 15, 2008 at 09:47:24AM +0100, Gabriel Barazer wrote:
> Hi
> 
> Thanks for the netdev Cc, I didn't know where to write to the "network 
> guys".

except I just noticed I got it wrong: it's netdev@vger.kernel.org, and
I omitted the "vger" part. That's what is expected when posting before
caffeine :-)

Feel free to repost the whole issue overthere (along with your new tests)
if you don't get useful replies in a few days.

> By the way thanks for replying. It's hard to explain and describe a 
> problem when you know people will ask you hundreds of questions related 
> to application-level problems, or not reply because web/mysql problems 
> are so common and generally not related to any kernel issue.

What caught my attention was the usual "3s delay", which is purely TCP
and application-independant.

> On 03/15/2008 7:58:49 AM +0100, Willy Tarreau <w@1wt.eu> wrote:
> >
> >You should carefully check the the SYN-ACK received by the client has a
> >correct checksum ("cksum OK" in tcpdump output). It would be possible
> >that for some reason, something on the network randomly corrupts it.
> 
> I used to use TCP offloading one time, and by the way never had a 
> problem with it. Besides just to be sure, I have been able to reproduce 
> the problem without any offload engine enabled (= not compiled into the 
> kernel, mainly because it seems to hang the kernel at boot in 2.6.24.3). 
> So I assume that is not the problem

OK

> I use wireshark to analyse my pcap files and it says the checksum is 
> correct on all packets.

OK

> >Also, you say you have netfilter with conntrack. Is this on the client ?
> >If so, you should try disabling it to rule out any possible bug in the
> >connection tracking.
> 
> I have the conntrack  on both the client and server, and unfortunately 
> can't disable it now on the client (I use it only for the REDIRECT 
> target on a precise destination address and port, not MySQL related), 
> however I will test today and disable it on the server, after I get some 
> sleep (although I think the issue is on the client).

I'm sure it's a client issue too, that's why it would be reasonable to
be able to try without conntrack. Can't you use a TCP proxy instead of
REDIRECT ? Also, you said that you also noticed the same behaviour in
other environments, maybe there you can disable conntrack ?

Willy

