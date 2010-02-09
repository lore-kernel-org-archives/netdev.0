From: Dan Smith <danms@us.ibm.com>
Subject: Network device and namespace checkpoint/restart (v2)
Date: Tue,  9 Feb 2010 13:25:09 -0800
Message-ID: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
Cc: netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:45114 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab0BIV1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 16:27:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds checkpoint/restart support for network namespaces,
as well as the network devices within.  Currently supports veth and loopback
device types.

Major changes from last time[1] are:

 - Add a per-device ndo_checkpoint() operation which simultaneously
   isolates the checkpoint layer from the network device's checkpoint
   function and internal data, and also provides a better way to
   determine checkpointability of a given interface.
 - Use RTNL to create the veth pair as userspace would, to avoid the
   need to call directly into RTNL and veth internals

With this set, I'm able to checkpoint and restart a running sendmail
instance that is inside a private network namespace with a veth tunnel
to the outside world.  Applies on top of -rc3 with my other two patches
from earlier today.

1: https://lists.linux-foundation.org/pipermail/containers/2010-January/022549.html

