From: David Miller <davem@davemloft.net>
Subject: Re: Refactor Netlink connector?
Date: Sun, 28 May 2006 23:36:49 -0700 (PDT)
Message-ID: <20060528.233649.22498001.davem@davemloft.net>
References: <Pine.LNX.4.64.0605271223390.12872@d.namei>
	<Pine.LNX.4.64.0605271303050.13104@d.namei>
	<20060528153321.GB31822@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, tgraf@suug.ch,
	sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25751
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751145AbWE2Ggk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 May 2006 02:36:40 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060528153321.GB31822@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sun, 28 May 2006 19:33:21 +0400

> Does SELinux have security handlers for each type of possible ioctls
> over the world? Each ioctl number is like each netlink type of message,
> but instead there is only one check per ioctl syscall as long as lsm
> hook for socket's send/recv syscall. 

Yes, the problem is similar to what the compat layer needs to face.
But I think James will tell us that SELinux has a way that it handles
the mess that is ioctl(). :-)

More to the point I think that none of this will be handled
transparently unless the onus is put on new netlink module users.
Ie. make the register of a netlink subsystem user (either direct
netlink or via generic netlink) fail if the operations don't
provide the SELinux handlers.

Otherwise, the SELinux folks will continually be playing catchup
writing the handlers.  That doesn't scale.

