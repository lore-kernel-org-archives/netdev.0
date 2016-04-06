From: "Franklin S Cooper Jr." <fcooper@ti.com>
Subject: Boot failure when using NFS on OMAP based evms
Date: Wed, 6 Apr 2016 18:12:42 -0500
Message-ID: <570597EA.3040902@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>, <nsekhar@ti.com>,
	<linux-omap@vger.kernel.org>
To: <samanthakumar@google.com>, <willemb@google.com>,
	<edumazet@google.com>, <tony@atomide.com>, <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

Currently linux-next is failing to boot via NFS on my AM335x GP evm,
AM437x GP evm and Beagle X15. I bisected the problem down to the commit
"udp: remove headers from UDP packets before queueing".

I had to revert the following three commits to get things working again:

e6afc8ace6dd5cef5e812f26c72579da8806f5ac
udp: remove headers from UDP packets before queueing

627d2d6b550094d88f9e518e15967e7bf906ebbf
udp: enable MSG_PEEK at non-zero offset

b9bb53f3836f4eb2bdeb3447be11042bd29c2408
sock: convert sk_peek_offset functions to WRITE_ONCE


I'm using omap2plus_defconfig for my config.

Below bootlogs are from my AM335x GP evm:

Working
http://pastebin.ubuntu.com/15661989/ (Linux-next 3 patches reverted)

Failing
http://pastebin.ubuntu.com/15661318/ (Linux-next)
