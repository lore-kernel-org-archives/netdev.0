From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5 net-next] inet: kill smallest_size and smallest_port
Date: Wed, 21 Dec 2016 13:30:03 -0500 (EST)
Message-ID: <20161221.133003.1401543777326711002.davem@davemloft.net>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
        <1482264424-15439-3-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, kraigatgoog@gmail.com,
        eric.dumazet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964833AbcLUSaG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 13:30:06 -0500
In-Reply-To: <1482264424-15439-3-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Tue, 20 Dec 2016 15:07:01 -0500

> In inet_csk_get_port we seem to be using smallest_port to figure out where the
> best place to look for a SO_REUSEPORT sk that matches with an existing set of
> SO_REUSEPORT's.  However if we get to the logic
> 
> if (smallest_size != -1) {
> 	port = smallest_port;
> 	goto have_port;
> }
> 
> we will do a useless search, because we would have already done the
> inet_csk_bind_conflict for that port and it would have returned 1, otherwise we
> would have gone to found_tb and succeeded.  Since this logic makes us do yet
> another trip through inet_csk_bind_conflict for a port we know won't work just
> delete this code and save us the time.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

So the "all else being equal, use 'tb' with smallest socket count" logic
wasn't being used at all?

Instead of removing it why don't we make it work properly again?  Something
obviously broke it somewhere along the line, because I am pretty sure this
heuristic worked at some point in the past.
