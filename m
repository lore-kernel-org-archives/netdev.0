From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Fri, 17 Jun 2016 01:15:41 +0200
Message-ID: <1202f4bd-ef27-8143-8067-2bba56b7355c@stressinduktion.org>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:40140 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751711AbcFPXPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 19:15:45 -0400
In-Reply-To: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2016 19:51, Tom Herbert wrote:
> Transports over UDP is intended to encapsulate TCP and other transport
> protocols directly and securely in UDP.
> 
> The goal of this work is twofold:
> 
> 1) Allow applications to run their own transport layer stack (i.e.from
>    userspace). This eliminates dependencies on the OS (e.g. solves a
>    major dependency issue for Facebook on clients).
> 
> 2) Make transport layer headers (all of L4) invisible to the network
>    so that they can't do intrusive actions at L4. This will be enforced
>    with DTLS in use.
> 
> Note that #1 is really about running a transport stack in userspace
> applications in clients, not necessarily servers. For servers we
> intend to modified the kernel stack in order to leverage existing
> implementation for building scalable serves (hence these patches).
> 
> This is described in more detail in the Internet Draft:
> https://tools.ietf.org/html/draft-herbert-transports-over-udp-00
> 
> In Part I we implement a straightforward encapsulation of TCP in GUE.
> The implements the basic mechanics of TOU encapsulation for TCP,
> however does not yet implement the IP addressing interactions so
> therefore so this is not robust to use in the presence of NAT.
> TOU is enabled per socket with a new socket option. This
> implementation includes GSO, GRO, and RCO support.
> 
> These patches also establish the baseline performance of TOU
> and isolate the performance cost of UDP encapsulation. Performance
> results are below.
> 
> Tested: Various cases of TOU with IPv4, IPv6 using TCP_STREAM and
> TCP_RR. Also, tested IPIP for comparing TOU encapsulation to IP
> tunneling.

Thinking about middleboxes again:

E.g. https://tools.ietf.org/html/rfc6347#section-4.2.3 states that DTLS
packets are not allowed to be fragmented. Because of this and
furthermore because of the impossibility of clamp-mss-to-pmtu to work
anymore, do you have any idea on how reliable this can work?

Or is your plan to use a smaller MSS on all paths by default?

Thanks,
Hannes
