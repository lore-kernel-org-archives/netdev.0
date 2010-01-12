From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Tue, 12 Jan 2010 12:59:36 -0800
Message-ID: <4B4CE2B8.1040702@redfish-solutions.com>
References: <201001121432.43301.schmto@hrz.tu-chemnitz.de> <20100112.121607.39835310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:43072 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752214Ab0ALU7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:59:46 -0500
In-Reply-To: <20100112.121607.39835310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2010 12:16 PM, David Miller wrote:
> 
> You can't do any of these things you are doing, I've basically been
> ignoring all of these crazy diffserv patches, they're nuts!
> 
> The TOS socket option has a meaning and behavior defined by the BSD
> sockets interface many years ago.  And you cannot and must not change
> the behavior of those system calls because applications are written to
> the current behavior and you will break them.  Protecting the new
> behavior with a kernel config option is a non-starter, it's pointless
> because no distribution is going to enable a kernel option that
> knowingly breaks applications.
> 
> And it is also possible to set the TOS field however you desire using
> what the kernel currently provides, we do not preclude proper diffserv
> support, the BSD socket interfaces allow that just fine.
> 
> And you can also do diffserv by classifying traffic and setting the
> TOS field using either the packet scheduler, or even netfilter.
> 
> Linux supports diffserv fully and just fine, you just can't see it :-)
> 
> Please stop submitting these patches without first having at least a
> real discussion and understanding of how this stuff works.
> 
> Thanks.

I disagree.

The TOS socket option means "use these bits as the value of iphdr->ip_tos exactly as I'm giving them to you".

That hasn't changed.

What has changed is how network equipment is required to interpret the meaning of those bits.

As for "And you cannot and must not change the behavior of those system calls because applications are written to the current behavior and you will break them."  For me, this is the real non-starter.  Even if we pass the bits "as is" to the network, if the network is applying entirely new semantics (and when I say "entirely new", I mean those mandated since 1998), then compatibility in the host kernel API doesn't matter a hoot since the packets will still be handled by every transited router according to the modern semantics.

I note that the lower two bits of the TOS field were appropriated for ECN at the same time, and that hasn't broken a thing.

