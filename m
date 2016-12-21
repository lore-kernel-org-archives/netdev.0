From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 net-next] inet: replace ->bind_conflict with
 ->rcv_saddr_equal
Date: Wed, 21 Dec 2016 13:28:22 -0500 (EST)
Message-ID: <20161221.132822.1241833684791529358.davem@davemloft.net>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
        <1482264424-15439-2-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, kraigatgoog@gmail.com,
        eric.dumazet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33738 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752026AbcLUS2Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 13:28:24 -0500
In-Reply-To: <1482264424-15439-2-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Tue, 20 Dec 2016 15:07:00 -0500

> The only difference between inet6_csk_bind_conflict and inet_csk_bind_conflict
> is how they check the rcv_saddr.  Since we want to be able to check the saddr in
> other places just drop the protocol specific ->bind_conflict and replace it with
> ->rcv_saddr_equal, then make inet_csk_bind_conflict the one true bind conflict
> function.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

This may be a nice cleanup and all, but realize that if we do actually
have to traverse a lot of sockets this code has become significantly
slower.

We now have to execute a hard to predict indirect call for every
socket we process on the list.

This is almost certainly why we had two seperate functions expanded
rather than having an AF-specific helper execute in the inner loop
of a generic function.
