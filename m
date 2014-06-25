From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] nftables 0.3 release
Date: Wed, 25 Jun 2014 17:52:10 +0200
Message-ID: <20140625155210.GA31550@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net,
	kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60351 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757236AbaFYPwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 11:52:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

The Netfilter project presents:

        nftables 0.3

This release contains bug fixes, syntax cleanups, new features, support
for all new features contained in the recent 3.15 kernel release.

Syntax changes
==============

* More compact syntax for the queue action, eg.

nft add rule test input queue num 1

  You can also express the multiqueue as a range, followed by options.

nft add rule test input queue num 1-3 bypass fanout

  Or just simply the options:

nft add rule test input queue bypass

New features
============

* Match input and output bridge interface name through 'meta ibriport'
  and 'meta obriport', e.g.

nft add rule bridge filter input meta ibriport br0 counter

* netlink event monitor, to monitor ruleset events, set changes, etc.
  The most simple way to monitor updates is to run:

nft monitor

* New transaction infrastructure - fully atomic updates for all
  object available in the upcoming 3.16.

Bug fixes
=========

* Fix crash when nftables / nfnetlink support is not present in the kernel.

* Fix crash when using multi-line command in interative mode, eg.

nft -i
nft> list \
.... table filter

* Fix wrong packet and bytes counters when the rule-set is reloaded.

* Fix wrong output in chain priorities

        type route hook output priority -1
                                        ^^

* Fix assertion when using non-equal comparison, eg.

nft add rule filter input ip protocol != icmp counter
                                      ^^

* Range inversions, eg.

nft add rule filter input != 192.168.0.1-192.168.0.10
                          ^^

* Fix 'meta iiftype ether'.

* Fix the udplite selector, due to missing code in the tokenizer.

Ongoing works
=============

There are several open fronts in terms of development:

* Full logging support for all the supported families (ip, ip6, arp,
  bridge and inet).

* Masquerading support.

* Better reject support, which allows you to indicate the explicit reject
  reason.

* JSON/XML import.

* reverse set lookups, eg.

ip saddr != { 192.168.0.1, 192.168.0.10, 192.168.0.11 }
         ^^

* more new meta selectors, packet type (unicast, multicast and broadcast),
  cpu, physical interface, realm, etc.

* support for concatenations - multidimensional exact matches in O(1) types

* set selection - automatic selection of the optimal set
  implementation.

Resources
=========

The nftables code can be obtained from:

* http://netfilter.org/projects/nftables/downloads.html
* ftp://ftp.netfilter.org/pub/nftables
* git://git.netfilter.org/nftables

To build the code, you libnftnl and libmnl are required:

* http://netfilter.org/projects/libnftnl/index.html

Thanks
======

Thanks to all our contributors, testers and bug reporters, whom have
all helped to improve nftables.

On behalf of the Netfilter Core Team,
Happy bytecode execution :)
