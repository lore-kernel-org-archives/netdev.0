From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host
	communication.
Date: Mon, 15 Dec 2008 09:48:19 +0200
Message-ID: <20081215074819.GV5555@redhat.com>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com> <20081214.224436.55256593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44360 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743AbYLOHsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 02:48:05 -0500
Content-Disposition: inline
In-Reply-To: <20081214.224436.55256593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 14, 2008 at 10:44:36PM -0800, David Miller wrote:
> From: Gleb Natapov <gleb@redhat.com>
> Date: Sun, 14 Dec 2008 13:50:55 +0200
> 
> > It is undesirable to use TCP/IP for this purpose since network
> > connectivity may not exist between host and guest and if it exists the
> > traffic can be not routable between host and guest for security reasons
> > or TCP/IP traffic can be firewalled (by mistake) by unsuspecting VM user.
> 
> I don't really accept this argument, sorry.
> 
> If you can't use TCP because it might be security protected or
> misconfigured, adding this new stream protocol thing is not one
> bit better.  It doesn't make any sense at all.
> 
It can be _accidentally_ misconfigured. Just think about sysadmin that has
a remote access to a VM guest and he doesn't even know that it is a VM.
(He can easily find this out but why should he care?). The sysadmin knows
that the first rule of firewalling is deny everything and than allow
what you want to be allowed, so that what he does and cut communication
between host and guest. The problem with networking is that it is visible
to VM user and perceived to be under full user control.

> Also, if TCP could be "misconfigured" this new thing could just as
> easily be screwed up too.  And I wouldn't be surprised to see a whole
> bunch of SELINUX and netfilter features proposed later for this and
> then we're back to square one.
> 
It not only can be missconfigured it may not exist between guest and
host at all. IP connectivity between guest and host is not mandatory
and we don't want to make it such. It is like saying "who needs
serial console, just use ssh". And what subnet should be used for this
purpose? Who will solve conflicts? I can see why SELINUX features may
be proposed for vmchannel, but netfilter doesn't make sense for it.
And vmchannel also has other advantages over TCP/IP: less overhead and
better "naming". By better naming I mean that guest should not guess
(or require configuration) what ip:port should be used for cut&paste,
it just connects to address "cut&paste".

> You guys really need to rethink this.  Either a stream protocol is a
> workable solution to your problem, or it isn't.
> 
Stream protocol is workable solution for us, but we need it out of band
in regard to networking and as much zero config as possible. If we will
use networking how can it be done without additional configuration (and
reconfiguration can be required after migration BTW)

--
			Gleb.
