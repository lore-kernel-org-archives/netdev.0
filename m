From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth update for 2.6
Date: Tue, 26 Sep 2006 12:46:21 +0200
Message-ID: <1159267581.1235.10.camel@localhost>
References: <1158868040.11194.56.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:32168 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1751131AbWIZKpu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 06:45:50 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1158868040.11194.56.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> here are the pending patches that didn't make it into the 2.6.18 kernel
> release. I have some additional fixes, but all of them need some more
> additional testing from my side.

it seems that you haven't pulled in these changes so far. So I didn't
rebase the tree and simply pushed some additional ones on top of it. All
three of them address the issues we had with non-blocking connects.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 include/net/bluetooth/hci.h      |    6 ++++++
 include/net/bluetooth/hci_core.h |   12 +++++++++---
 net/bluetooth/af_bluetooth.c     |    2 +-
 net/bluetooth/hci_conn.c         |   31 +++++++++++++++++++++++++++----
 net/bluetooth/hci_core.c         |    3 +++
 net/bluetooth/hci_event.c        |   25 ++++++++++++++++++++++++-
 net/bluetooth/hci_sysfs.c        |   24 ++++++++++++++++++++++++
 net/bluetooth/rfcomm/core.c      |    2 +-
 8 files changed, 95 insertions(+), 10 deletions(-)

through these ChangeSets:

Marcel Holtmann <marcel@holtmann.org> Tue, 26 Sep 2006 09:43:48 +0200 

    [Bluetooth] Support create connection cancel command
    
    In case of non-blocking connects it is possible that the last user
    of an ACL link quits before the connection has been fully established.
    This will lead to a race condition where the internal state of a
    connection is closed, but the actual link has been established and is
    active. In case of Bluetooth 1.2 and later devices it is possible to
    call create connection cancel to abort the connect. For older devices
    the disconnect timer will be used to trigger the needed disconnect.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Sat, 23 Sep 2006 09:57:20 +0200 

    [Bluetooth] Read local version information on device init
    
    The local version information are needed to identify certain feature
    sets of devices. They must be read on device init and stored for later
    use. It is also possible to access them through the device model.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Sat, 23 Sep 2006 09:54:38 +0200 

    [Bluetooth] Return EINPROGRESS for non-blocking socket calls
    
    In case of non-blocking socket calls we should return EINPROGRESS
    and not EAGAIN.
    
    Signed-off-by: Ulisses Furquim <ulissesf@gmail.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



