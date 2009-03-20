From: Jens Stroebel <drifter@bcsoft.de>
Subject: e1000 under VMware doesn't work since 2.6.27.16 - BISECTED
Date: Fri, 20 Mar 2009 17:41:10 +0100
Message-ID: <49C3C726.4000405@bcsoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: netdev list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:55594 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242AbZCTQlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 12:41:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

		Hello,

we're using virtual machines under VMware with the e1000 emulated
network card.

While trying to update the kernel, we had to recogize that the
networking doesn't work anymore since kernel 2.6.27.16.

The e1000 kernel module gets loaded and the interface SEEMS to be
brought up correctly; however, there's no networking possible afterwards
(no hosts in the network reachable by "ping", for example).


I bisected the behaviour to the following commit (commit-ID from the
2.6.27 git repo):
#####################################################################

c6ac5fe00250faed88fb258d7ec91ec99bbe1e95 is first bad commit
commit c6ac5fe00250faed88fb258d7ec91ec99bbe1e95
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Tue Jan 27 16:41:58 2009 -0800

    e1000: fix bug with shared interrupt during reset

    commit 15b2bee22a0390d951301b53e83df88d0350c499 upstream.

    A nasty bug was found where an MTU change (or anything else that
caused a
    reset) could race with the interrupt code.  The interrupt code was
entered
    by a shared interrupt during the MTU change.

    This change prevents the interrupt code from running while the
driver is in
    the middle of its reset path.

    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
#####################################################################

As this is a relatively common card (and a relatively common usage under
VMware), has anyone experienced something similar?

If any more data is needed, let me know.

		greets,
		  jens
