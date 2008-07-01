From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 01 Jul 2008 09:32:47 -0400
Message-ID: <486A31FF.8050201@garzik.org>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57850 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbYGANc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 09:32:56 -0400
In-Reply-To: <486A2487.2010303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Evgeniy Polyakov wrote:
>> On Tue, Jul 01, 2008 at 01:53:43PM +0200, Patrick McHardy 
>> (kaber@trash.net) wrote:
>>> My two main objections are that this only works for TCP and
>>> can be trivially evaded. What use cases does it have?
>>
>> Yes, it is TCP specific module.
> 
> What about the use cases? I certainly like the idea you suggest in
> your blog ("Ever dreamt to block all Linux users in your network
> from accessing internet and allow full bandwidth to Windows worm?")
> :) But something this easy to evade doesn't seem to provide a real
> benefit for a firewall.
> 
> I can see that something like "Block IE6 running on Windows version X"
> might be useful (NUFW can do this I think), but that needs support
> from the host.

Not addressing Evgeniy's module but speaking generally...

It sure would be nice for regular socket applications to have an easy, 
unprivileged way to query the OS fingerprint information of a given socket.

Speaking purely from a userspace application API perspective, it would 
be most useful for an app to be able to stop OSF collection, start OSF 
collection, and query OSF stats.  start/stop would be a refcount that 
disables in-kernel OSF when not in use.

To present a specific use case:  I would like to know if incoming SMTP 
connections are Windows or not.  That permits me to better determine if 
the incoming connection is a hijacked PC or not -- it becomes a useful 
factor in spamassassin scoring.

In this case, incoming SMTP is -always- TCP, thus being a TCP-specific 
module is not a problem.  You cover a huge swath of apps even if the 
module is TCP-specific.

Another use case is validating whether a browser is "lying" about its 
OS, when parsing HTTP user-agent info, or in general when any remote 
agent is "lying" about its OS.  Security software can use that as an 
additional red-flag factor.

	Jeff



