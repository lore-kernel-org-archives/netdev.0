From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv4: arp: Always update neighbour address when a gratuitous arp is received
Date: Fri, 20 Dec 2013 23:30:40 +0100
Message-ID: <20131220223040.GC14073@order.stressinduktion.org>
References: <1387565962-9357-1-git-send-email-noureddine@aristanetworks.com> <20131220140617.09a672f7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Salam Noureddine <noureddine@aristanetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43599 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab3LTWal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 17:30:41 -0500
Content-Disposition: inline
In-Reply-To: <20131220140617.09a672f7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 02:06:17PM -0800, Stephen Hemminger wrote:
> On Fri, 20 Dec 2013 10:59:22 -0800
> Salam Noureddine <noureddine@aristanetworks.com> wrote:
> 
> > Gratuitous arp packets are useful in switchover scenarios to update
> > client arp tables as quickly as possible. Currently, the mac address
> > of a neighbour is only updated after a locktime period has elapsed
> > since the last update. In most use cases such delays are unacceptable
> > for network admins. Moreover, the "updated" field of the neighbour
> > stucture doesn't record the last time the address of a neighbour
> > changed but records any change that happens to the neighbour. This is
> > clearly a bug since locktime uses that field as meaning "addr_updated".
> > With this observation, I was able to perpetuate a stale address by
> > sending a stream of gratuitous arp packets spaced less than locktime
> > apart.
> > 
> > Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
> 
> Doesn't this make the system more vulnerable to ARP spoofing?

Yes it does, but also it is supposed to work like this with garp, I fear.
Making this conditional on some sysctl would not help either, because
normal behaviour for clients should be, that e.g. the router switches
and sends out garp, that the client should pick those announcements up
as soon as possible. That is also how arp_notify is supposed to work.

Greetings,

  Hannes
