From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] net: fix a potential rcu_read_lock() imbalance in rt6_fill_node()
Date: Tue, 27 Mar 2012 17:54:02 -0700
Message-ID: <4F72612A.4020305@intel.com>
References: <4F71EF2A.8020507@candelatech.com> <1332877149.3547.24.camel@edumazet-glaptop> <1332878032.3547.39.camel@edumazet-glaptop> <20120327.182208.806353341087563847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, greearb@candelatech.com,
	netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	paulmck@linux.vnet.ibm.com, davej@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55023 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755884Ab2C1AyD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 20:54:03 -0400
In-Reply-To: <20120327.182208.806353341087563847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/27/2012 3:22 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 27 Mar 2012 21:53:52 +0200
> 
>> Commit f2c31e32b378 (net: fix NULL dereferences in check_peer_redir() )
>> added a regression in rt6_fill_node(), leading to rcu_read_lock()
>> imbalance.
>>
>> Thats because NLA_PUT() can make a jump to nla_put_failure label.
>>
>> Fix this by using nla_put()
>>
>> Many thanks to Ben Greear for his help
>>
>> Reported-by: Ben Greear <greearb@candelatech.com>
>> Reported-by: Dave Jones <davej@redhat.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Great work everyone.
> 
> I'll apply this and queue it up for stable soon.
> 
> In other news, I think the days of hidden gotos from the NLA macros
> should be over.  I'll work in net-next to redo this so that the
> gotos must be explicitly coded and therefore be visible when people
> audit these routines.
> 
> Thanks!
> --

I can clean up the ./net/dcb/ code if it will save you some time?

.John
