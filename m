From: David Howells <dhowells@redhat.com>
Subject: Re: private netdev flags into UAPI?
Date: Mon, 26 Nov 2012 09:22:41 +0000
Message-ID: <10845.1353921761@warthog.procyon.org.uk>
References: <50B1CC1B.20104@mellanox.com>
Cc: dhowells@redhat.com, netdev <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5672 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753996Ab2KZJWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 04:22:47 -0500
In-Reply-To: <50B1CC1B.20104@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@mellanox.com> wrote:

> not sure if this has been brought up before, but I realized that the private
> IFF_yyy netdevice flags which weren't exposed to user space so far have been
> moved to include/uapi/linux/if.h, isn't that wrong?

They were exposed to userspace already.  On my Fedora 16 test box, I see:

	[root@andromeda ~]# grep -r IFF_EBRIDGE /usr/include/linux
	/usr/include/linux/if.h:#define IFF_EBRIDGE     0x2             /* Ethernet bridging device.    */

which is from:

	kernel-headers-3.3.6-3.fc16.x86_64

which was built before UAPI proper started going in:

	[root@andromeda ~]# rpm -qfi /usr/include/linux/if.h | grep "Build Date"
	Build Date  : Wed 16 May 2012 23:05:59 BST

Looking at commit 607ca46e97a1b6594b29647d98a32d545c24bdff, I see:

	--------------------------- include/uapi/linux/if.h ---------------------------
	similarity index 100%
	rename from include/linux/if.h
	rename to include/uapi/linux/if.h

so my script just moved it without alteration.

David
