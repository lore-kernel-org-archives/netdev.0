From: Andi Kleen <andi@firstfloor.org>
Subject: Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: 20 Feb 2007 11:50:13 +0100
Message-ID: <p73d545drx6.fsf@bingen.suse.de>
References: <20070219231447.GA4400@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: bert hubert <bert.hubert@netherlabs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:38119 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbXBTJuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 04:50:18 -0500
In-Reply-To: <20070219231447.GA4400@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bert hubert <bert.hubert@netherlabs.nl> writes:

> Hi people,
> 
> I'm trying to save people the cost of buying extra servers by making
> PowerDNS (GPL) ever faster, but I've hit a rather fundamental problem.
> 
> Linux 2.6.20-rc4 appears to take 4 microseconds on my P4 3GHz for a
> non-blocking UDPv4 recvfrom() call, both on loopback and ethernet.

P4s are pretty slow at taking locks (or rather doing atomical operations)
and there are several of them in this path. You could try it with a UP
kernel. Actually hotunplugging the other virtual CPU should be sufficient 
with recent kernels.

Also BTW RDTSC on P4 is not very accurate for small measurements
because it has a quite high overhead by itself, i would suggest
running it in a loop.

-Andi
