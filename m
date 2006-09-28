From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth update for 2.6
Date: Thu, 28 Sep 2006 23:14:44 +0200
Message-ID: <1159478084.21120.75.camel@localhost>
References: <1158868040.11194.56.camel@localhost>
	 <1159267581.1235.10.camel@localhost>
	 <20060927.225817.106770711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:34230 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1750953AbWI1VOK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 17:14:10 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060927.225817.106770711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> > > here are the pending patches that didn't make it into the 2.6.18 kernel
> > > release. I have some additional fixes, but all of them need some more
> > > additional testing from my side.
> > 
> > it seems that you haven't pulled in these changes so far. So I didn't
> > rebase the tree and simply pushed some additional ones on top of it. All
> > three of them address the issues we had with non-blocking connects.
> 
> I applied all of your fixes into my tree, sorry for taking so long.

no big problem. If you haven't synced with Linus yet, then I have two
small additional fixes that should go in with the others.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 net/bluetooth/hci_event.c |    8 ++++----
 net/bluetooth/hci_sysfs.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

through these ChangeSets:

Marcel Holtmann <marcel@holtmann.org> Thu, 28 Sep 2006 20:23:29 +0200 

    [Bluetooth] Fix section mismatch of bt_sysfs_cleanup()
    
    The bt_sysfs_cleanup() is marked with __exit attribute, but it will
    be called from an __init function in the error case. So the __exit
    attribute must be removed.
    
    Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Tue, 26 Sep 2006 22:18:03 +0200 

    [Bluetooth] Don't update disconnect timer for incoming connections
    
    In the case of device pairing the only safe method is to establish
    a low-level ACL link. In this case, the remote side should not use
    the disconnect timer to give the other side the chance to enter the
    PIN code. If the disconnect timer is used, the connection will be
    dropped to soon, because it is impossible to identify an actual user
    of this link.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



