From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: dhclient, checksum and tap
Date: Fri, 25 Jun 2010 18:10:08 +0300
Message-ID: <20100625151008.GA17911@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert.xu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61701 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992Ab0FYPPB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 11:15:01 -0400
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o5PFF0US023379
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 11:15:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!
I've been looking at the issue of checksum on
dhcp packets: to recap, 8dc4194474159660d7f37c495e3fc3f10d0db8cc
added a way for af_packet sockets to get the packet status.
Unfortunately not all dhcp clients caught up with
this development, so they are still broken
when both server and client run on the same host,
e.g. with bridge+tap.

And of course virtualization adds another way to run
old dhcp clients, so userspace virtio net in qemu has
a hack to detect DHCP and fill in the checksum.
I guess we could add this in vhost, as well.

However, one wonders whether the tap driver is a better place
for this work-around, that would help all users.
Any objections against putting such code in tap?

-- 
MST
