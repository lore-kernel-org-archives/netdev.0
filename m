From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 1 Jul 2008 17:39:58 +0400
Message-ID: <20080701133958.GA11317@2ka.mipt.ru>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net> <486A31FF.8050201@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40520 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754962AbYGANjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 09:39:48 -0400
Content-Disposition: inline
In-Reply-To: <486A31FF.8050201@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff.

On Tue, Jul 01, 2008 at 09:32:47AM -0400, Jeff Garzik (jeff@garzik.org) wrote:
> It sure would be nice for regular socket applications to have an easy, 
> unprivileged way to query the OS fingerprint information of a given socket.
> 
> Speaking purely from a userspace application API perspective, it would 
> be most useful for an app to be able to stop OSF collection, start OSF 
> collection, and query OSF stats.  start/stop would be a refcount that 
> disables in-kernel OSF when not in use.
> 
> To present a specific use case:  I would like to know if incoming SMTP 
> connections are Windows or not.  That permits me to better determine if 
> the incoming connection is a hijacked PC or not -- it becomes a useful 
> factor in spamassassin scoring.
> 
> In this case, incoming SMTP is -always- TCP, thus being a TCP-specific 
> module is not a problem.  You cover a huge swath of apps even if the 
> module is TCP-specific.
> 
> Another use case is validating whether a browser is "lying" about its 
> OS, when parsing HTTP user-agent info, or in general when any remote 
> agent is "lying" about its OS.  Security software can use that as an 
> additional red-flag factor.

It is possible right now in OSF: it sends a netlink notification to
userspace about received and matched packet. We can even think some more
about reverse channel - to inform kernel about some steps for this
match, it requires root priveledges though. It can also be done via
different channel (like running script to install iptables rule).

-- 
	Evgeniy Polyakov
