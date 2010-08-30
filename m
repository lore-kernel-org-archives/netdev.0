From: Thomas Voegtle <tv@lio96.de>
Subject: PF_NETLINK, SOCK_DGRAM, 2 => EPROTONOSUPPORT
Date: Mon, 30 Aug 2010 12:02:51 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1008301158360.28658@er-systems.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from er-systems.de ([85.25.136.202]:36136 "EHLO er-systems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837Ab0H3KKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 06:10:25 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by er-systems.de (Postfix) with ESMTP id DCD5E17403B
	for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 12:02:52 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by er-systems.de (Postfix) with ESMTPS id B444E174012
	for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 12:02:52 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,


This code snippet:
#include <sys/socket.h>
#include <linux/netlink.h>
int main() {
         socket(PF_NETLINK, SOCK_DGRAM, NETLINK_USERSOCK);
         return 0;
}

ends up with:

socket(PF_NETLINK, SOCK_DGRAM, 2) = -1 EPROTONOSUPPORT (Protocol not 
supported)

since 2.6.33.

I bisected it down to:
974c37e9d88c3e5a3e56eb98cb9c84232eb2bdcb is the first bad commit
commit 974c37e9d88c3e5a3e56eb98cb9c84232eb2bdcb
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Sat Jan 30 10:05:05 2010 +0000

     netlink: fix for too early rmmod


This is strange, because the code snippet even fails on a monolithic 
kernel.
When I revert this commit on top of 2.6.36-rc3, it works.

Was this intended, that this code snippet doesn't work this way anymore or
is this just a bug?


       Thomas

