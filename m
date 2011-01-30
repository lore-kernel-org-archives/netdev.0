From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: Add compat ioctl support for the ipv4 multicast ioctl SIOCGETSGCNT
Date: Sun, 30 Jan 2011 19:59:53 +0100
Message-ID: <201101301959.53661.arnd@arndb.de>
References: <m18vy3uof7.fsf@fess.ebiederm.org> <201101301326.14390.arnd@arndb.de> <m18vy2tfzn.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56072 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab1A3TAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 14:00:16 -0500
In-Reply-To: <m18vy2tfzn.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 30 January 2011 19:15:40 Eric W. Biederman wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
> 
> > On Sunday 30 January 2011 03:15:56 Eric W. Biederman wrote:
> >> A trivial compact ioctl implementation would conflict with:
> >> SIOCAX25ADDUID
> >> SIOCAIPXPRISLT
> >> SIOCGETSGCNT_IN6
> >> SIOCGETSGCNT
> >> SIOCRSSCAUSE
> >> SIOCX25SSUBSCRIP
> >> SIOCX25SDTEFACILITIES
> >
> > Since you have compiled the list, did you see if these are all handled
> > compatible, or would it make sense to create patches for the other
> > protocols as well, to handle them individually?
> 
> I didn't look.  I had a specific pre-existing application that didn't
> work, and those ioctls meant the existing solutions for network compat
> ioctls wouldn't work and the infrastructure needed fixing.

I just looked at all users of SIOCPROTOPRIVATE to check what else
is needed here, for reference. What I found is:

* appletalk, ipx and x25 have full compat_ioctl support.
* ax25 needs some real work in order to be usable in compat mode.
* phonet and rose use only data structures that are compatible,
  so adding support would be trivial.
* ip multicast actually needs support for SIOCGETVIFCNT in
  addition to SIOCGETSGCNT to be complete.
* ipv6 multicast needs the same patch as ipv4 multicast for
  SIOCGETMIFCNT_IN6/SIOCGETSGCNT_IN6.

It would probably be a good idea if someone could complete the
work on ipv4/v6 multicast compat_ioctl, on top of your patch.

	Arnd
