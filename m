From: David Miller <davem@davemloft.net>
Subject: HFI driver...
Date: Tue, 26 Apr 2011 12:06:24 -0700 (PDT)
Message-ID: <20110426.120624.226758363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dykmanj@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752466Ab1DZTG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 15:06:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I started reviewing this monster, here is what I have to say so far:

1) Get rid of this character device.

   If you want to dump traces, and allow the user to submit commands,
   you can create a generic netlink family to do this.

   Netlink will get rid of the ugly char device, and allow you to
   extend your interfaces in a backwards compatible way in the future.

2) You add casts to of_get_property() return values.  This should never
   be necessary.

   of_get_property() returns "const void *" which means as long as
   you declare your pointers "const" (which you don't) no cast is
   necessary.

   You are bypassing the read-only protection property values have
   by doing these casts, get rid of them and declare your pointers
   with "const".

3) Most uses of "long long" and "int" are suspect.

   If you need a 64-bit type, use "u64".  If you need a 32-bit
   type, use "u32".  If you need them to be signed use "s64"
   and "s32" respectively.

4) When you add the "is_userspace" variable to hfidd_cmd_write() there
   are not users.  This will produce warnings with gcc-4.6.0, do not
   add function variables that are set but never used.

5) Similar comment about using non-fixed-sized types in the definition
   of base_hdr, hfi_rdma_extended_hdr et al.  Never use generic C types
   like "unsigned int" and "unsigned long long".  Instead, always use
   well defined, fixed sized types like "u32", "u64", etc.
