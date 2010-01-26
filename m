From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Netlink usage question (for bonding comm with userspace)
Date: Mon, 25 Jan 2010 16:48:21 -0800
Message-ID: <15914.1264466901@death.nxdomain.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:42306 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095Ab0AZAsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 19:48:32 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0Q0hAnM014783
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 17:43:10 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0Q0mQuv118632
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 17:48:27 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0Q0mQme032689
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 17:48:26 -0700
Received: from death.nxdomain.ibm.com (sig-9-65-116-6.mts.ibm.com [9.65.116.6])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVin) with ESMTP id o0Q0mPUe032526
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 17:48:26 -0700
Received: from localhost ([127.0.0.1] helo=death.nxdomain.ibm.com)
	by death.nxdomain.ibm.com with esmtp (Exim 4.69)
	(envelope-from <fubar@us.ibm.com>)
	id 1NZZbR-00048h-Ue
	for netdev@vger.kernel.org; Mon, 25 Jan 2010 16:48:22 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Could any netlink gurus comment on my questions?  I'm hoping to
figure out the right way to do what I need without working up patches
that end up being excellent examples of the wrong way.  I've looked
through the kernel, and it's almost a cases of too many choices (private
netlink, rtnetlink, connector, genetlink) to sort through.

	Background: I'm working on a bonding mode that involves two-way
communication between bonding itself and a user-space daemon, and I'm
trying to determine the best way to utilize netlink for this project
with an eye towards forwards compatibility with future expansion (e.g.,
general bonding setup via netlink).  For purposes of discussion, the
communication requires that bonding-specific requests, responses and
asynchronous events flow in both directions.

	I could, for this project, use a netlink_kernel_create and
socket(AF_NETLINK) pair to perform the communication (presumably adding
a NETLINK_BONDING or the like to <linux/netlink.h>).

	That, however, wouldn't dovetail with moving control of bonding
into iproute2 ("ip link add link bond0 type bond mode whatever"), and it
seems suboptimal to have two independent netlink gizmos in bonding.  I'm
not planning to implement full bonding control via netlink at this time,
but I don't want to do anything that would cause difficulty for doing so
in the future.

	I've done some prototyping with working through the existing
rtnetlink infrastructure, adding an RTNLGRP_BONDING, AF_BONDING, etc,
vaguely paralleling how the bridge code is architected.  What's unclear
to me is how to insert the bonding-specific request / response message
types into the rtnetlink infrastructure, or, indeed, if this is simply
not the right way to go about this.

	So, in summary:

	For user / kernel communications via netlink: private socket,
add to rtnetlink API, or something else (connector, genetlink, ...)?

	Is having private socket netlink and rtnetlink in the same
module a reasonable methodology?

	If rtnetlink is suitable, basic "do this" or "don't do this"
thoughts?  The various HOWTOs google finds for me concentrate on the
mechanisms, less so on interface selection / design.

	Thoughts?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
