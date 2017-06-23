From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipmr: restrict mroute "queue full"
 warning to related error values
Date: Fri, 23 Jun 2017 14:47:39 -0400 (EDT)
Message-ID: <20170623.144739.1791220360024944932.davem@davemloft.net>
References: <20170621175811.16940-1-julien@arista.com>
        <20170623.133947.433422648753848462.davem@davemloft.net>
        <bc8a9605-2df7-821f-5103-e9acb4482f3a@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julien@arista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bc8a9605-2df7-821f-5103-e9acb4482f3a@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julien Gomes <julien@arista.com>
Date: Fri, 23 Jun 2017 10:52:26 -0700

> On 06/23/2017 10:39 AM, David Miller wrote:
> 
>> From: Julien Gomes <julien@arista.com>
>> Date: Wed, 21 Jun 2017 10:58:10 -0700
>>
>>> When sending a cache report on mroute_sk, mroute will emit a
>>> "pending queue full" warning for every error value returned by
>>> sock_queue_rcv_skb().
>>> This warning can be misleading, for example on the EPERM error value
>>> that sk_filter() can return.
>>>
>>> Restricting this warning to only ENOMEM or ENOBUFS seems more
>>> appropriate.
>>>
>>> Signed-off-by: Julien Gomes <julien@arista.com>
>> Incorrect, no other error codes are possible.
>>
>> We never attach a socket filter to these kernel internal sockets,
>> therefore sk_filter() is not even applicable in this analysis.
>>
>> Therefore, -ENOBUFS and -ENOMEM are the only errors we can ever see
>> returned from sock_queue_rcv_skb().
>>
>> This goes for your second patch as well.
> 
> Up to now I would agree, but now that cache reports are also sent
> through Netlink, wouldn't it make sense to allow the user of mroute_sk
> to attach a filter to it in order to not receive cache reports on it?

There is not visibility of this socket outside of the kernel.

I doubt it would ever be exported in any way, and until it would
be so worrying about this is truly a huge waste of time and developer
resources.

Thank you.
