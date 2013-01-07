From: Rami Rosen <ramirose@gmail.com>
Subject: [RFC PATCH v2 net-next 0/2] Remove NETIF_F_NETNS_LOCAL from software devices.
Date: Mon,  7 Jan 2013 09:19:34 +0200
Message-ID: <1357543176-15352-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	ebiederm@xmission.com, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:39372 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab3AGHVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 02:21:07 -0500
Received: by mail-ee0-f50.google.com with SMTP id b45so9452974eek.9
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2013 23:21:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NETIF_F_NETNS_LOCAL feature is set in some network device,  
we do not allow this device to be moved from one network namespace 
to another (see dev_change_net_namespace()). Vlan device is not considered 
a local device and does not have the NETIF_F_NETNS_LOCAL feature. There is no 
reason that software devices like ppp and bridge will set the
NETIF_F_NETNS_LOCAL feature. This patchset removes NETIF_F_NETNS_LOCAL
from ppp and bridge devices.

* Changes from v1
	Do not remove NETIF_F_NETNS_LOCAL from vxlan devices. Moving vxlan device 
	to a different namesapce does not move the state of the UDP socket related 
	to this vxlan device (Following Stephen Hemminger comment).
	
Rami Rosen (2):
  [RFC PATCH v2 net-next 1/3] ppp: remove NETIF_F_NETNS_LOCAL from ppp
    device features.
  [RFC PATCH v2 net-next 2/3] bridge: remove NETIF_F_NETNS_LOCAL from
    bridge device features.

 drivers/net/ppp/ppp_generic.c | 1 -
 net/bridge/br_device.c        | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

-- 
1.7.11.7
