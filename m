From: =?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [resend] [PATCH] IPv4: Reset scope when changing address
Date: Sun, 24 Feb 2008 19:12:38 +0100
Message-ID: <873arib4vd.fsf@obelix.mork.no>
References: <87bq6hazvo.fsf@obelix.mork.no>
	<20080217.222245.132418529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41201 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbYBXSMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2008 13:12:47 -0500
Received: from obelix.mork.no (obelix.mork.no [IPv6:2001:16d8:ffb4:2:205:4eff:fe4c:7769])
	by canardo.mork.no (8.13.8/8.13.8) with ESMTP id m1OICe4a009300
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 24 Feb 2008 19:12:41 +0100
Received: from bjorn by obelix.mork.no with local (Exim 4.63)
	(envelope-from <bjorn@mork.no>)
	id 1JTLL4-0007mr-QY
	for netdev@vger.kernel.org; Sun, 24 Feb 2008 19:12:38 +0100
In-Reply-To: <20080217.222245.132418529.davem@davemloft.net> (David Miller's
	message of "Sun, 17 Feb 2008 22:22:45 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Please clear up all of the inline mime tag stuff in your
> outgoing emails.  Your description and patch is very difficult
> to read because of this.

Ouch, sorry. I wish I could blame my user agent, but this was mostly my
sausage fingers..

New attempt:


This bug did bite at least one user, who did have to resort to rebooting
the system after an "ifconfig eth0 127.0.0.1" typo.  

Deleting the address and adding a new is a less intrusive workaround.
But I still beleive this is a bug that should be fixed.  Some way or
another.

Another possibility would be to remove the scope mangling based on
address.  This will always be incomplete (are 127/8 the only address
space with host scope requirements?)



We set the scope to RT_SCOPE_HOST if an IPv4 interface is configured
with a loopback address (127/8).  The scope is never reset, and will
remain set to RT_SCOPE_HOST after changing the address. This patch
resets the scope if the address is changed again, to restore normal
functionality.

Signed-off-by: Bjorn Mork <bjorn@mork.no>
---
 devinet.c |    1 +
 1 file changed, 1 insertion(+)


--- linux-2.6.24-rc8.orig/net/ipv4/devinet.c	2008-01-16 05:22:48.000000000 +0100
+++ linux-2.6.24-rc8/net/ipv4/devinet.c	2008-01-23 19:17:30.000000000 +0100
@@ -753,6 +753,7 @@
 			inet_del_ifa(in_dev, ifap, 0);
 			ifa->ifa_broadcast = 0;
 			ifa->ifa_anycast = 0;
+			ifa->ifa_scope = 0;
 		}
 
 		ifa->ifa_address = ifa->ifa_local = sin->sin_addr.s_addr;
