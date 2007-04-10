From: David Hollis <dhollis@davehollis.com>
Subject: phylib usage
Date: Tue, 10 Apr 2007 14:41:01 -0400
Message-ID: <1176230461.7526.20.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:42911 "EHLO
	vms044pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030525AbXDJUZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 16:25:53 -0400
Received: from smtp.davehollis.com ([71.251.104.144])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JGA00LRSU30KPF4@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 10 Apr 2007 15:25:48 -0500 (CDT)
Received: from localhost (chef.davehollis.com [127.0.0.1])
	by smtp.davehollis.com (Postfix) with ESMTP id D365525F8019	for
 <netdev@vger.kernel.org>; Tue, 10 Apr 2007 16:25:47 -0400 (EDT)
Received: from smtp.davehollis.com ([127.0.0.1])
	by localhost (chef.davehollis.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vwKNtWXGPc05 for <netdev@vger.kernel.org>; Tue,
 10 Apr 2007 16:25:44 -0400 (EDT)
Received: from [192.168.1.102] (unknown [208.251.158.37])
	(using SSLv3 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)	by smtp.davehollis.com (Postfix)
 with ESMTP id 7BA3425F8001	for <netdev@vger.kernel.org>; Tue,
 10 Apr 2007 16:25:44 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been keeping an eye on PHYLIB since it's addition to the kernel
some time ago and I'm a bit curious as to why it doesn't seem to have
much up-take among other drivers.  A quick check of the kernel source
shows only two users (AU1000 and gianfar) and both look to be embedded
type devices.  Are there fundamental issues with PHYLIB that prevent it
from being more widely used?  Is it an element of "the driver ain't
broke, I'm not going to rework my PHY handling at this point"?  Is PHY
handling something that is just too difficult to fully abstract with
various specialty nics?

To semi-answer one of my own questions, I was hoping to use PHYLIB with
asix.c (a USB Ethernet driver) since the newer devices now have external
PHYs and it appears that there are quite a few different ones in use by
various OEMs but I found that the locking in use wasn't amenable to USB
operations, since USB calls can sleep.  This doesn't seem like an
insurmountable problem however.

The main reason I even ask is that it seems rather odd to have so many
drivers that seem to have the same PHY's and yet each driver has to deal
with various errata and quirks of the PHY.  Having it all abstracted
makes for one location to deal with things and everybody wins.

-- 
David Hollis <dhollis@davehollis.com>

