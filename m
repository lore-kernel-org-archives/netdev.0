From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: bonding and IPv6 "doesn't work"?
Date: Tue, 12 Jul 2011 18:25:16 +0200
Message-ID: <4E1C756C.2010700@wpkg.org>
References: <4E1C70D5.6060806@wpkg.org> <20110712161455.GD909183@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.virtall.com ([178.63.195.102]:35446 "EHLO mail.virtall.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753829Ab1GLQZT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 12:25:19 -0400
In-Reply-To: <20110712161455.GD909183@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.07.2011 18:14, David Lamparter wrote:
> On Tue, Jul 12, 2011 at 06:05:41PM +0200, Tomasz Chmielewski wrote:
>> I make a bond0 of two interfaces, eth0 and eth1.
>
> What kind of device do you have on the other side of those links?

It's a virtual machine.
So, a bridge of the host.

I know it doesn't make much sense to set up bonding in a virtual 
machine, but I'm trying to determine what possible problems I might have 
in a production environment (and got stuck at the very beginning).

IPv4 bonding works fine in this setup.


>> bond0: IPv6 duplicate address 2a01:4f8:120:14c4::1247 detected!
> [...]
>> However if I start bonding with just one interface, add IPv6 address to
>> it, then use ifenslave to add a second interface, I'm able to reach the
>> hosts in the internet.
>
> Yeah, when you add the IPv6 address, IPv6 ND does its job and announces
> your presence/does DAD.

Shouldn't this disable DAD? Or am I confusing something here?

net.ipv6.conf.eth0.accept_dad = 0
net.ipv6.conf.eth1.accept_dad = 0


> Your bonding peer is probably looping those
> packets back on the other link, most likely because...
>
>> Bonding Mode: load balancing (round-robin)
>
> ... most likely because you maybe have a switch on the other side, and
> that switch expects you to do 802.3ad?

It's a virtual machine, so the host shouldn't know or care much about 
802.3ad (I think!).


-- 
Tomasz Chmielewski
http://wpkg.org
