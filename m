From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: unregister_netdev() deadlock
Date: Wed, 27 Feb 2008 15:44:54 +0000
Message-ID: <1204127094.11318.0.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: matthew.hattersley@vaioni.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:58367 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751642AbYB0PrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 10:47:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I have doubts about unregister the netdevice.

Scenario
I have two netdevice entities. I wish to unregister one entity.

struct net_device *dev1;
struct net_device *dev2;

dev1->timer = XXX;
dev2->timer = YYY;

dev1->ioctl() {

...
case delete_other:
            unregister_netdev(dev2);
            free_netdev(dev2);
            return 0;
...
}

The dev2->refcnt is not zero in this case. unregister_netdev(dev2) cause
deadlock. Could you tell me why it happens?.


It works smoothly when we call the unregister_netdev(dev2) from
cleanup_module(). dev2->refcnt is not zero in this case.  Still it is
able to unregister.


Thanks
Jeba


