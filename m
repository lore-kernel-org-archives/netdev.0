From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH v3 -mm 0/9] netconsole: Multiple targets and dynamic reconfigurability
Date: Mon, 30 Jul 2007 08:17:41 +0530
Message-ID: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43447 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936492AbXG3CfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 22:35:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[0/9] netconsole: Multiple targets and dynamic reconfigurability

This is v3 of the patchset, the previous versions are available at:
http://lkml.org/lkml/2007/7/4/107
http://lkml.org/lkml/2007/7/10/78

Diffed against 2.6.23-rc1-git6 (6c8dca5d as of writing), but applies
successfully to 2.6.23-rc1-mm1 as well.

Patches 1-5 are okay-to-apply to current mainline -git, I think.

Patches 6-9 introduce the new functionality and are requested for
inclusion in -mm.

[1/9] netconsole: Cleanups, codingstyle, prettyfication
[2/9] netconsole: Remove bogus check
[3/9] netconsole: Simplify boot/module option setup logic
[4/9] netconsole: Use netif_running() in write_msg()
[5/9] netconsole: Add some useful tips to documentation
[6/9] netconsole: Introduce netconsole_target
[7/9] netconsole: Introduce netconsole_netdev_notifier
[8/9] netconsole: Support multiple logging targets
[9/9] netconsole: Support dynamic reconfiguration using configfs

Changes since v2:
=================

* "enabled" must be defined outside #ifdef NETCONSOLE_DYNAMIC

* Some simple enhancements to documentation

* Drop the use of "unlikely" from a condition where I'd got the
  common case wrong

About this patchset:
====================

What?

Support multiple remote logging targets in netconsole. Also, ability to
dynamically add or remove targets or modify parameters (IP, port, remote
MAC address) of targets at runtime, from userspace, using configfs.

Why?

>From Keiichi Kii's original post:

[...] current netconsole is not flexible. For example, if you want to change
ip address for logging agent, in the case of built-in netconsole, you can't
change config except for changing boot parameter and rebooting your system,
or in the case of module netconsole, you need to remove it and reload
with different parameters. [...] and we have been losing serial console
port with PCs and Servers.

(... and especially laptops, I would add.)


Satyam
