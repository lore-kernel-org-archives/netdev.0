From: David Miller <davem@davemloft.net>
Subject: ipv4 gro receive IHL
Date: Mon, 22 Oct 2012 23:46:06 -0400 (EDT)
Message-ID: <20121022.234606.1841113825492366676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484Ab2JWDqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 23:46:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric why do we force the length field to '5' in the ip_fast_csum()
call of inet_gro_receive()?  This happened as part of commit
a9e050f4e7f9d36afe0dcc0bddba864ee442715e ("net: tcp: GRO should be ECN
friendly")

This will cause the checksum check to fail for any IPV4 header with
options.

If that's intended, the way to do this is to reject by checking the
iph->ihl value, rather than doing so obscurely via the checksum call.
