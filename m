From: Alan <alan@lxorguk.ukuu.org.uk>
Subject: CAIF device
Date: Thu, 1 Apr 2010 16:09:16 +0100
Message-ID: <20100401160916.2a2574f4@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:38528 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752251Ab0DAPFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 11:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was reading through the CAIF code and I noticed a couple of bugs

Doesn't check there is a write method so set on a read only
device it's not good news (doubly so as there seem to be no
permission checks ?) plus no permissions checks and also the
following which looks unsafe

        dev_close(ser->dev);
        unregister_netdevice(ser->dev);
        list_del(&ser->node);
        debugfs_deinit(ser);

Now ser is the netdev private data so what stops it going away when
unregister_netdev is called ?

Secondly tty devices are ref counted and this for some reason didn't get
fixed in the driver yet.

[Patches to follow for the write and kref bugs, the others need the
authors and someone who knows the netdev code these days to fix]
