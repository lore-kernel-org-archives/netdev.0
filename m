From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] Fixing a bug in team driver due to incorrect
 'unsigned int' to 'int' conversion
Date: Fri, 07 Oct 2016 23:51:00 -0400 (EDT)
Message-ID: <20161007.235100.1185623091934128288.davem@davemloft.net>
References: <14617987.qnk3Z4yzn3@zbook>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: alexandre.sidorenko@hpe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59938 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752142AbcJHDvE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 23:51:04 -0400
In-Reply-To: <14617987.qnk3Z4yzn3@zbook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Date: Fri, 07 Oct 2016 09:02:33 -0400

> Roundrobin runner of team driver uses 'unsigned int' variable to count
> the number of sent_packets. Later it is passed to a subroutine
> team_num_to_port_index(struct team *team, int num) as 'num' and when
> we reach MAXINT (2**31-1), 'num' becomes negative.
> 
> This leads to using incorrect hash-bucket for port lookup
> and as a result, packets are dropped. The fix consists of changing 
> 'int num' to 'unsigned int num'. Testing of a fixed kernel shows that
> there is no packet drop anymore.
> 
> 
> Signed-off-by: Alex Sidorenko <alexandre.sidorenko@hpe.com>

Applied and queued up for -stable, thanks.
