From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] netfilter fixes for net
Date: Sat,  5 Apr 2014 18:03:42 +0200
Message-ID: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34322 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752959AbaDEQEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2014 12:04:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following patchset contains Netfilter fixes for your net tree, they
are:

* Use 16-bits offset and length fields instead of 8-bits in the conntrack
  extension to avoid an overflow when many conntrack extension are used,
  from Andrey Vagin.

* Allow to use cgroup match from LOCAL_IN, there is no apparent reason
  for not allowing this, from Alexey Perevalov.

* Fix build of the connlimit match after recent changes to let it scale
  up that result in a divide by zero compilation error in UP, from
  Florian Westphal.

* Move the lock out of the structure connlimit_data to avoid a false
  sharing spotted by Eric Dumazet and Jesper D. Brouer, this needed as
  part of the recent connlimit scalability improvements, also from
  Florian Westphal.

* Add missing module aliases in xt_osf to fix loading of rules using
  this match, from Kirill Tkhai.

* Restrict set names in nf_tables to 15 characters instead of silently
  trimming them off, from me.

* Fix wrong format in nf_tables request module call for chain types,
  spotted by Florian Westphal, patch from me.

* Fix crash in xtables when it fails to copy the counters back to userspace
  after having replaced the table already.

You can pull these changes from:
