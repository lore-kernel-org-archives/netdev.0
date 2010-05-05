From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/6] netns support in the kobject layer
Date: Tue, 04 May 2010 17:35:54 -0700
Message-ID: <m1d3xb4239.fsf@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34611 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933808Ab0EEAgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 20:36:12 -0400
In-Reply-To: <m1fx3hk6gw.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 30 Mar 2010 11\:30\:23 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With the tagged sysfs support finally merged into Greg's tree,
it is time for the last little bits of work to get the kobject
layer and network namespaces to play together properly.

These patches are roughly evenly divided between network layer work
and sysfs layer work.  Last time this conundrum came up I believe
we decided that the easiest way to handle this was for Greg to carry
all of the patches.  David, Greg does that still make sense?

This patchset adds:
- kobject layer support for sending events in all network namespaces
- netlink support for filtering broadcast packets based on attributes
  of the destination socket.
- Enabling the network namespace support for sysfs and the kobject layer.

 include/linux/kobject.h  |    1 +
 include/linux/netlink.h  |    4 ++
 lib/kobject_uevent.c     |  108 +++++++++++++++++++++++++++++++++++++++++-----
 net/Kconfig              |    8 +++
 net/core/dev.c           |   28 ++----------
 net/core/net-sysfs.c     |   62 ++++++++++++++++++++------
 net/core/net-sysfs.h     |    1 -
 net/netlink/af_netlink.c |   21 ++++++++-
 8 files changed, 181 insertions(+), 52 deletions(-)
