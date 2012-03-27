From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: fix a potential rcu_read_lock() imbalance in rt6_fill_node()
Date: Tue, 27 Mar 2012 13:17:09 -0700
Message-ID: <4F722045.80902@candelatech.com>
References: <4F70E308.7070908@candelatech.com>  <20120326.174945.1186427809261872546.davem@davemloft.net>  <4F70E560.3020102@candelatech.com>  <4F70F688.6050108@candelatech.com>  <1332805148.3547.14.camel@edumazet-glaptop>  <4F71EF2A.8020507@candelatech.com>  <1332877149.3547.24.camel@edumazet-glaptop> <1332878032.3547.39.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dave Jones <davej@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36449 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab2C0URW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 16:17:22 -0400
In-Reply-To: <1332878032.3547.39.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2012 12:53 PM, Eric Dumazet wrote:
> Commit f2c31e32b378 (net: fix NULL dereferences in check_peer_redir() )
> added a regression in rt6_fill_node(), leading to rcu_read_lock()
> imbalance.
>
> Thats because NLA_PUT() can make a jump to nla_put_failure label.
>
> Fix this by using nla_put()
>
> Many thanks to Ben Greear for his help
>
> Reported-by: Ben Greear<greearb@candelatech.com>
> Reported-by: Dave Jones<davej@redhat.com>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>

This does indeed fix the problem for me (tested in the 3.0.25 kernel).
So, please feel free to add:

Tested-by: Ben Greear <greearb@candelatech.com>

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
