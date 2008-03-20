From: Willy Tarreau <w@1wt.eu>
Subject: Re: [2.6.24.3][net] bug: TCP 3rd handshake abnormal timeouts
Date: Thu, 20 Mar 2008 05:34:28 +0100
Message-ID: <20080320043428.GE8159@1wt.eu>
References: <47DB28E9.4050309@oxeva.fr> <20080315065739.GL8953@1wt.eu> <20080315065849.GA11817@1wt.eu> <47DB8D1C.7020006@oxeva.fr> <20080315085527.GA6239@1wt.eu> <47DD49C6.8040400@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2544 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750743AbYCTEkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 00:40:07 -0400
Content-Disposition: inline
In-Reply-To: <47DD49C6.8040400@oxeva.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 16, 2008 at 05:24:38PM +0100, Gabriel Barazer wrote:
> Hi
> 
> On 03/15/2008 9:55:27 AM +0100, Willy Tarreau <w@1wt.eu> wrote:
> >On Sat, Mar 15, 2008 at 09:47:24AM +0100, Gabriel Barazer wrote:
> >
> >Feel free to repost the whole issue overthere (along with your new tests)
> >if you don't get useful replies in a few days.
> >
> >>By the way thanks for replying. It's hard to explain and describe a 
> >>problem when you know people will ask you hundreds of questions related 
> >>to application-level problems, or not reply because web/mysql problems 
> >>are so common and generally not related to any kernel issue.
> >
> >What caught my attention was the usual "3s delay", which is purely TCP
> >and application-independant.
> >
> >
> >>>Also, you say you have netfilter with conntrack. Is this on the client ?
> >>>If so, you should try disabling it to rule out any possible bug in the
> >>>connection tracking.
> >>I have the conntrack  on both the client and server, and unfortunately 
> >>can't disable it now on the client (I use it only for the REDIRECT 
> >>target on a precise destination address and port, not MySQL related), 
> >>however I will test today and disable it on the server, after I get some 
> >>sleep (although I think the issue is on the client).
> >
> >I'm sure it's a client issue too, that's why it would be reasonable to
> >be able to try without conntrack. Can't you use a TCP proxy instead of
> >REDIRECT ? Also, you said that you also noticed the same behaviour in
> >other environments, maybe there you can disable conntrack ?
> 
> I was able to reproduce the bug multiple times without conntrack nor 
> netfilter on the client and the server(I recompiled the kernel disabling 
> the entire netfilter subsystem). The 3-second problem still occurs so we 
> can completely rule out contrack-related bugs.

ah, that's excellent. Now we're pretty sure that either :
  a) the packets are corrupted somewhere (but I believe you told that the
     checksums were indicated OK)
  b) there is something wrong on the client side, either a major tuning
     issue (but I don't see what may cause this) or a bug (more likely)

Do you know how many sessions/s you have between the client and the server ?
Is it in the order of 10, 100, 1000, 10000 ? Also, I think that a full
capture of the same session on both ends will help (either join the pcap
file, or decode it with tcpdump -Snevvvs0). For instance, it would be
possible (though strange) that for an unknown reason, sometimes the ARP
entry for the client in the server table is wrong, so that the client does
not accept the SYN-ACK. However, sniffing it in promiscuous mode still shows
it.

Regards,
Willy

