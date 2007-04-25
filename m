From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netlink locking warnings in 2.6.21-rc7-mm1
Date: Wed, 25 Apr 2007 12:44:49 -0700
Message-ID: <20070425124449.98bf091c.akpm@linux-foundation.org>
References: <E1HgVxj-0003U6-00@gondolin.me.apana.org.au>
	<462F54F3.9050306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:56717 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030998AbXDYTpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 15:45:33 -0400
In-Reply-To: <462F54F3.9050306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I just retested bare net-2.6.22, pulled 30 minutes ago.  I got just one
warning:


PM: Removing info for No Bus:0000:06:0b.0
eth0: no IPv6 routers present
ipw2200: Radio Frequency Kill Switch is On:
Kill switch must be turned off for wireless networking to work.
PM: Adding info for No Bus:eth1
ipw2200: Detected geography ZZA (11 802.11bg channels, 13 802.11a channels)
ipw2200: Failed to send WEP_KEY: Aborted due to RF kill switch.
ipw2200: Failed to send WEP_KEY: Command timed out.
ipw2200: Failed to send WEP_KEY: Command timed out.
BUG: at kernel/mutex-debug.c:82 debug_mutex_unlock()
 [<c012d18a>] debug_mutex_unlock+0x5a/0x134
 [<c02d67e2>] __mutex_unlock_slowpath+0x9d/0xcf
 [<f8c3618b>] ipw_wx_set_encode+0x0/0x82 [ipw2200]
 [<c028b92c>] rtnl_unlock+0xa/0x29
 [<c0286651>] dev_ioctl+0x3d0/0x402
 [<c014b078>] __handle_mm_fault+0x7c6/0x7e8
 [<c01a649b>] selinux_file_alloc_security+0x1f/0x40
 [<c027b943>] sock_ioctl+0x0/0x1be
 [<c0162925>] do_ioctl+0x19/0x4d
 [<c0162b58>] vfs_ioctl+0x1ff/0x216
 [<c0162bbb>] sys_ioctl+0x4c/0x65
 [<c0103b0c>] syscall_call+0x7/0xb
 [<c02d0000>] unix_dgram_sendmsg+0x76/0x400
 =======================

It's 100% reproducible here, using
http://userweb.kernel.org/~akpm/config-sony.txt





The weird ASSERT_RTNL warnings aren't there, so something else in -mm
(prior to git-net.patch in the series file) would appear to be interacting
with net changes.

