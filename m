From: Cong Wang <amwang@redhat.com>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and bonding
 devices
Date: Tue, 08 Jun 2010 16:36:06 +0800
Message-ID: <4C0E00F6.8020409@redhat.com>
References: <4C062CBD.7090906@redhat.com>	<20100604191841.GM7497@gospo.rdu.redhat.com>	<4C0CC29D.9070507@redhat.com> <20100607.030108.235696592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, fubar@us.ibm.com, fbl@sysclose.org,
	linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com, jmoyer@redhat.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533Ab0FHIcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 04:32:35 -0400
In-Reply-To: <20100607.030108.235696592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/10 18:01, David Miller wrote:
> From: Cong Wang<amwang@redhat.com>
> Date: Mon, 07 Jun 2010 17:57:49 +0800
>
>> Hmm, I still feel like this way is ugly, although it may work.
>> I guess David doesn't like it either.
>
> Of course I don't like it. :-)
>
> I suspect the locking scheme will need to be changed.
>
> Besides, if we're going to hack this up and do write lock attempts in
> the read locking paths, there is no point in using a rwlock any more.
> And I'm personally in disfavor of all rwlock usage anyways (it dirties
> the cacheline for readers just as equally for writers, and if the
> critically protected code path is short enough, that shared cache
> line atomic operation will be the predominant cost).
>
> So I'd say, 1) make this a spinlock and 2) try to use RCU for the
> read path.
>
> That would fix everything.

Yeah, agreed. Even not talking about netconsole, bonding code
does have locking problems, netconsole just makes this problem
clear.

I will try your suggestions above.

Thanks!
