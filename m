From: David Miller <davem@davemloft.net>
Subject: Re: CPU usage for IPSec in Linux 2.6.38
Date: Tue, 10 Jan 2012 22:34:39 -0800 (PST)
Message-ID: <20120110.223439.142967999090229499.davem@davemloft.net>
References: <A2354B6A9F807641B21EEABD666ECEEA02596D98@XMB-BGL-416.cisco.com>
	<1326209072.19095.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<A2354B6A9F807641B21EEABD666ECEEA02596E0B@XMB-BGL-416.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: nbn@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321Ab2AKGeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 01:34:50 -0500
In-Reply-To: <A2354B6A9F807641B21EEABD666ECEEA02596E0B@XMB-BGL-416.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Naveen B N (nbn)" <nbn@cisco.com>
Date: Wed, 11 Jan 2012 08:20:12 +0530

> Did anybody try creating IPSec Tunnels > 6000 in Linux
> And faced the same problem below.

The problem is that you must situate your rules according to
certain rules otherwise performance will suffer greatly.

You must:

1) Predominantly use fully specified, non-wildcard, rules.

   These go into a special hash table which approaches complexity
   O(1).

2) If you absolutely must have wildcarded rules, only have an
   extremely small number of them.

   These go onto a linked list which is O(N).

There is no reasonable reason to have thousands of wildcarded
rules.

Thousands of fully specified non-wildcard rules are reasonable,
and what we optimize the IPSEC datastructures for.
