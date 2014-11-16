From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: Fix incorrect error code when adding an
 unreachable route
Date: Sun, 16 Nov 2014 14:16:38 -0500 (EST)
Message-ID: <20141116.141638.2195341594564232778.davem@davemloft.net>
References: <beb6c57fb3e1591346d64ac2fcdb354cd87987d4.1415963644.git.pmatilai@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmatilai@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbaKPTQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 14:16:41 -0500
In-Reply-To: <beb6c57fb3e1591346d64ac2fcdb354cd87987d4.1415963644.git.pmatilai@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Panu Matilainen <pmatilai@redhat.com>
Date: Fri, 14 Nov 2014 13:14:32 +0200

> Trying to add an unreachable route incorrectly returns -ESRCH if
> if custom FIB rules are present:
> 
> [root@localhost ~]# ip route add 74.125.31.199 dev eth0 via 1.2.3.4
> RTNETLINK answers: Network is unreachable
> [root@localhost ~]# ip rule add to 55.66.77.88 table 200
> [root@localhost ~]# ip route add 74.125.31.199 dev eth0 via 1.2.3.4
> RTNETLINK answers: No such process
> [root@localhost ~]#
> 
> Commit 83886b6b636173b206f475929e58fac75c6f2446 ("[NET]: Change "not found"
> return value for rule lookup") changed fib_rules_lookup()
> to use -ESRCH as a "not found" code internally, but for user space it
> should be translated into -ENETUNREACH. Handle the translation centrally in
> ipv4-specific fib_lookup(), leaving the DECnet case alone.
> 
> On a related note, commit b7a71b51ee37d919e4098cd961d59a883fd272d8
> ("ipv4: removed redundant conditional") removed a similar translation from
> ip_route_input_slow() prematurely AIUI.
> 
> Fixes: b7a71b51ee37 ("ipv4: removed redundant conditional")
> Signed-off-by: Panu Matilainen <pmatilai@redhat.com>

Applied and queued up for -stable, thanks.
