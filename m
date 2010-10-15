From: Andi Kleen <andi@firstfloor.org>
Subject: netlink versus pid namespaces
Date: Fri, 15 Oct 2010 16:23:57 +0200
Message-ID: <20101015142357.GA29321@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, xemul@openvz.org, kuznet@ms2.inr.ac.ru,
	virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40162 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756168Ab0JOOYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 10:24:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have been trying to figure out how pid namespaces interact
with netlink.

netlink uses pids (or really tids I hope?) to address sockets
associated with processes.

The netlink code passes around pids without caring much about 
the pid namespace.  It does pass around some information about the 
network namespace, but that doesn't help here because the pid
namespace is not necessarily related to the net namespace.

When the netlink consumer runs in kernel (like rtnetlink) and
happens to run in the same process context while receiving
and processing the data it should do the right thing because
it has the same pid namespace.

If it runs in some other process that is not guaranteed and
it may actually send the reply back to the wrong pid.

When a process receives netlink in user space and it isn't
in the same pid space as the sender it is unlikely that
the reply gets back.

Anything I'm missing here? 

Does netlink need to be extended? 
Or perhaps forbid passing netlink between name spaces?

Thanks,
-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
