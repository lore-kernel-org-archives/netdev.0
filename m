From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] info leak fixes in recvmsg
Date: Sun, 07 Apr 2013 16:31:17 -0400 (EDT)
Message-ID: <20130407.163117.265521959609997339.davem@davemloft.net>
References: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	aloisio.almeida@openbossa.org, acking@vmware.com,
	acme@ghostprotocols.net, dtor@vmware.com, georgezhang@vmware.com,
	gustavo@padovan.org, johan.hedberg@gmail.com,
	jon.maloy@ericsson.com, lauro.venancio@openbossa.org,
	marcel@holtmann.org, ralf@linux-mips.org, sameo@linux.intel.com,
	samuel@sortiz.org, sjur.brandeland@stericsson.com,
	ursula.braun@de.ibm.com, spender@grsecurity.net
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933523Ab3DGUbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 16:31:22 -0400
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Sun,  7 Apr 2013 13:51:46 +0200

> a few more info leak fixes in the recvmsg path. The error pattern here
> is the protocol specific recvmsg function is missing the msg_namelen
> assignment -- either completely or in early exit paths that do not
> result in errors in __sys_recvmsg()/sys_recvfrom() and, in turn, make
> them call move_addr_to_user(), leaking the then still uninitialized
> sockaddr_storage stack variable to userland.
> 
> My audit was initiated by a rather coarse fix of the leak that can be
> found in the grsecurity patch, putting a penalty on protocols complying
> to the rules of recvmsg. So credits for finding the leak in the recvmsg
> path in __sys_recvmsg() should go to Brad!
> 
> The buggy protocols/subsystems are rather obscure anyway. As a missing
> assignment of msg_namelen coupled with a missing filling of msg_name
> would only result in garbage -- the leak -- in case userland would care
> about that information, i.e. would provide a msg_name pointer. But
> obviously current userland does not.
> 
> While auditing the code for the above pattern I found a few more
> 'uninitialized members' kind of leaks related to the msg_name filling.
> Those are fixed in this series, too.
> 
> I have to admit, I failed to test all of the patches due to missing
> hardware, e.g. iucv depends on S390 -- hardware I've no access to :/

All applied and queued up for -stable, thanks!
