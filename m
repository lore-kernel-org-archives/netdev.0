From: Paul Moore <pmoore@redhat.com>
Subject: Problems with VSOCK?
Date: Wed, 20 Feb 2013 17:11:05 -0500
Message-ID: <6456403.c195oTrMFj@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Andy King <acking@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945Ab3BTWLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 17:11:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

I'm currently looking at the VSOCK implementation in netdev-next to determine 
what we need in the way of LSM hooks and I ran into a few things which look 
rather odd:

* net/vmw_sock/Kconfig

VMWARE_VMCI_SOCKETS depends on VMWARE_VMCI which doesn't look to be defined 
anywhere, help?  For what it is worth, removing the VMWARE_VMCI dependency 
seems to fix things.  Here is a simple patch to demonstrate the problem:

diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
index b5fa7e4..7c72881 100644
--- a/net/vmw_vsock/Kconfig
+++ b/net/vmw_vsock/Kconfig
@@ -17,7 +17,7 @@ config VSOCKETS
 
 config VMWARE_VMCI_VSOCKETS
 	tristate "VMware VMCI transport for Virtual Sockets"
-	depends on VSOCKETS && VMWARE_VMCI
+	depends on VSOCKETS
 	help
 	  This module implements a VMCI transport for Virtual Sockets.

* [include/]linux/vmw_vmci_defs.h
* [include/]linux/vmw_vmci_api.h
* [include/]linux/vm_sockets.h

This header files are included in vmci_transport_notify.h, and perhaps others, 
but don't seem to be present in the tree.  There may be others, these are just 
the first ones the compiler stumbled across.  Perhaps a missing git-add 
command?

* struct vmci_datagram

I can't find where this is defined, yet it is used in various places, 
including as a member in struct vmci_transport_packet.  Likely related to the 
missing header files.

* vmci_datagram_send(struct vmci_datagram *) {guessing at the prototype}

Same problem, I can't find where this is defined.

Perhaps I'm just being particularly stupid today (my apologies if that is the 
case), but I've refreshed my local git repository a few times now and double 
checked the mailing list and I haven't found anything.  Can you provide some 
help here?

Thanks,
-Paul

-- 
paul moore
security and virtualization @ redhat
