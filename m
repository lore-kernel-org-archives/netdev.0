From: Patrick McHardy <kaber@trash.net>
Subject: Re: request_module while holding rtnl semaphore
Date: Tue, 11 Jan 2005 22:05:07 +0100
Message-ID: <41E43F83.1090503@trash.net>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <41E34252.504@trash.net> <20050111094752.GD26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050111094752.GD26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>* Patrick McHardy <41E34252.504@trash.net> 2005-01-11 04:04
>
>>This patch got lost somehow. The act_api.c changes are actually
>>even more complicated because besides the action init path, changes
>>can also be made from classifiers in a deep call-chain. I hope
>>Thomas's recent changes make it easier to fix this, but I think
>>this patch should go in now anyway.
>>
>
>The action initialization is now done first and no classifier
>data is changed except for tp->root modifications which must not
>be undone so you can safely return EBUSY. rsvp might be an exception,
>I haven't looked too closely into it yet.
>
>tcindex returns EBUSY when a filter is changed which does not fit
>into the hashtable, so this must be changed.
>
It's -EAGAIN, so no problem, nothing returns this currently. I'm going to
send a patch later.

Regards
Patrick
