From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH 0/2] netlink: protection and workaround for too long mcast group name
Date: Tue, 19 Mar 2013 20:47:26 +0900
Message-ID: <1363693648-10015-1-git-send-email-yamato@redhat.com>
Cc: Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h219-110-095-248.catv01.itscom.jp ([219.110.95.248]:55726 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932483Ab3CSR2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:28:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You will see garbage at the end of line in the output of following command line:

	$ genl ctrl show | grep thermal_mc_group
        #1:  ID-0x2  name: thermal_mc_group^B

The type of structure field for "name" is char[16]:

    #define GENL_NAMSIZ	16	/* length of family name */
    ...
    struct genl_multicast_group {
            ...
	    char		name[GENL_NAMSIZ];
            ...
    };

strlen("thermal_mc_group") == 16 is too long for the array size.

This patch series provid a protection(patch for genetlink) for this 
kind of bug and workaround(patch for thermal). 

Masatake YAMATO (2):
  genetlink: trigger BUG_ON if a group name is too long
  thermal: shorten too long mcast group name

 include/linux/thermal.h | 2 +-
 net/netlink/genetlink.c | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

-- 
1.7.11.7
