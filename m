From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: do not trigger BUG_ON in
 sctp_cmd_delete_tcb
Date: Mon, 04 Nov 2013 00:47:37 -0500 (EST)
Message-ID: <20131104.004737.1541924078654523492.davem@davemloft.net>
References: <1383207212-21658-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab3KDFrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 00:47:41 -0500
In-Reply-To: <1383207212-21658-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 31 Oct 2013 09:13:32 +0100

> Introduced in f9e42b853523 ("net: sctp: sideeffect: throw BUG if
> primary_path is NULL"), we intended to find a buggy assoc that's
> part of the assoc hash table with a primary_path that is NULL.
> However, we better remove the BUG_ON for now and find a more
> suitable place to assert for these things as Mark reports that
> this also triggers the bug when duplication cookie processing
> happens, and the assoc is not part of the hash table (so all
> good in this case). Such a situation can for example easily be
> reproduced by:
> 
>   tc qdisc add dev eth0 root handle 1: prio bands 2 priomap 1 1 1 1 1 1
>   tc qdisc add dev eth0 parent 1:2 handle 20: netem loss 20%
>   tc filter add dev eth0 protocol ip parent 1: prio 2 u32 match ip \
>             protocol 132 0xff match u8 0x0b 0xff at 32 flowid 1:2
> 
> This drops 20% of COOKIE-ACK packets. After some follow-up
> discussion with Vlad we came to the conclusion that for now we
> should still better remove this BUG_ON() assertion, and come up
> with two follow-ups later on, that is, i) find a more suitable
> place for this assertion, and possibly ii) have a special
> allocator/initializer for such kind of temporary assocs.
> 
> Reported-by: Mark Thomas <Mark.Thomas@metaswitch.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks.
