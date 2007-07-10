From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [RFC][PATCH v2 -mm 0/9] netconsole: Multiple targets and dynamic reconfigurability
Date: Tue, 10 Jul 2007 14:49:20 +0530
Message-ID: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:42573 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755858AbXGJI5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 04:57:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[0/9] netconsole: Multiple targets and dynamic reconfigurability

This patchset is a rework of the original idea and patches posted by
Keiichi Kii and Takayoshi Kochi at: http://lkml.org/lkml/2007/6/13/72

This is v2 of the patchset, the previous version is available at:
http://lkml.org/lkml/2007/7/4/107

This is diffed against 2.6.22-rc6-mm1 + the earlier netpoll fixlet and the
configfs cleanup patches (those are already merged in -mm AFAIK, and hence
not reproduced here).

[1/9] netconsole: Cleanups, codingstyle, prettyfication
[2/9] netconsole: Remove bogus check
[3/9] netconsole: Simplify boot/module option setup logic
[4/9] netconsole: Add some useful tips to documentation
[5/9] netconsole: Introduce netconsole_target
[6/9] netconsole: Introduce netconsole_netdev_notifier
[7/9] netconsole: Use netif_running() in write_msg()
[8/9] netconsole: Support multiple logging targets
[9/9] netconsole: Support dynamic reconfiguration using configfs

Changes since v1:
=================

* Split / merge various patches in the patchset as suggested in reviews.

* Get rid of redundant "id" and "dev_status" fields.

* Use netif_running() instead of IFF_UP.

* Explain the boot/module option setup simplification and the netdev
  notifier patches in more detail (justify why they're good / required).

* Get rid of possible trailing newline from echo(1) in store_dev_name().

* Fix a panic bug -- now, when no boot/module option is specified, we
  skip only the part that creates and inserts param string-created
  targets. Rest of the initialization (notifier, configfs subsystem)
  is done as usual.

* Get rid of lock-skipping special-casing where possible.

* Use config_item_name() instead of "empty_item".

* Introduce netpoll_print_options() in netpoll and use it.

* Style cleanups (reduce #ifdefs, indentation, whitespace fixes, etc).

* Miscellaneous fixes in documentation (as suggested in reviews).

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

Kindly review and comment.

Satyam
