From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: mdb: zero out the local br_ip variable
 before use
Date: Wed, 08 Jul 2015 16:11:26 -0700 (PDT)
Message-ID: <20150708.161126.397827455847313183.davem@davemloft.net>
References: <1436277356-21404-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, vyasevich@gmail.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbbGHXL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:11:27 -0400
In-Reply-To: <1436277356-21404-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue,  7 Jul 2015 15:55:56 +0200

> Since commit b0e9a30dd669 ("bridge: Add vlan id to multicast groups")
> there's a check in br_ip_equal() for a matching vlan id, but the mdb
> functions were not modified to use (or at least zero it) so when an
> entry was added it would have a garbage vlan id (from the local br_ip
> variable in __br_mdb_add/del) and this would prevent it from being
> matched and also deleted. So zero out the whole local ip var to protect
> ourselves from future changes and also to fix the current bug, since
> there's no vlan id support in the mdb uapi - use always vlan id 0.
> Example before patch:
> root@debian:~# bridge mdb add dev br0 port eth1 grp 239.0.0.1 permanent
> root@debian:~# bridge mdb
> dev br0 port eth1 grp 239.0.0.1 permanent
> root@debian:~# bridge mdb del dev br0 port eth1 grp 239.0.0.1 permanent
> RTNETLINK answers: Invalid argument
> 
> After patch:
> root@debian:~# bridge mdb add dev br0 port eth1 grp 239.0.0.1 permanent
> root@debian:~# bridge mdb
> dev br0 port eth1 grp 239.0.0.1 permanent
> root@debian:~# bridge mdb del dev br0 port eth1 grp 239.0.0.1 permanent
> root@debian:~# bridge mdb
> 
> Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
> Fixes: b0e9a30dd669 ("bridge: Add vlan id to multicast groups")

Applied and queued up for -stable.
