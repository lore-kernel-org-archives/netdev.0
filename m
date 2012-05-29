From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 0/3] net: implement auto-loading of generic netlink modules
Date: Tue, 29 May 2012 15:30:39 -0400
Message-ID: <1338319842-18395-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	James Chapman <jchapman@katalix.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36031 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755277Ab2E2Ta4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 15:30:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric D. recently noted that the drop_monitor module didn't autoload when the
dropwatch user space utility started.  Looking into this I noted that theres no
formal macro set to define module aliases that can be used by a request module
call in the generic netlink family lookup path.  Currenlty the
net-pf-*-proto-*-type-<n> format is used, but the macros which form this expect
<n> to be a well defined integer, which generic netlink doesn't use for family
definitions.  So this series creates a new macro that create a
net-pf-*-proto-*-name format where name can be any arbitrary string, allowing us
to apend family-<x> where x is a generic netlink family name.  With these
macros, we can easily autoload modules that register generic netlink families

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: James Chapman <jchapman@katalix.com>
CC: David Miller <davem@davemloft.net>
