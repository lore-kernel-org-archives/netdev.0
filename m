From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net: fix /proc/net/dev regression
Date: Tue, 03 Apr 2012 08:36:48 -0700
Message-ID: <4F7B1910.3010701@candelatech.com>
References: <4F7A7C98.1030103@candelatech.com>  <1333431810.18626.37.camel@edumazet-glaptop>  <4F7A905B.3080107@candelatech.com>  <1333434995.18626.39.camel@edumazet-glaptop>  <1333436789.18626.43.camel@edumazet-glaptop> <1333441982.18626.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Mihai Maruseac <mmaruseac@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36075 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769Ab2DCPgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 11:36:53 -0400
In-Reply-To: <1333441982.18626.62.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2012 01:33 AM, Eric Dumazet wrote:
> Commit f04565ddf52 (dev: use name hash for dev_seq_ops) added a second
> regression, as some devices are missing from /proc/net/dev if many
> devices are defined.
>
> When seq_file buffer is filled, the last ->next/show() method is
> canceled (pos value is reverted to value prior ->next() call)
>
> Problem is after above commit, we dont restart the lookup at right
> position in ->start() method.
>
> Fix this by removing the internal 'pos' pointer added in commit, since
> we need to use the 'loff_t *pos' provided by seq_file layer.
>
> This also reverts commit 5cac98dd0 (net: Fix corruption
> in /proc/*/net/dev_mcast), since its not needed anymore.
>
> Reported-by: Ben Greear<greearb@candelatech.com>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> Cc: Mihai Maruseac<mmaruseac@ixiacom.com>

This appears to fix the problem.  I do find it mildly irritating
that the ordering is now random in /proc/net/dev, but I guess
that is the price of progress.

Tested-by:  Ben Greear <greearb@candelatech.com>

Thanks for the quick fix!

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
