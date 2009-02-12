From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink broadcast return value
Date: Thu, 12 Feb 2009 14:25:56 +0100
Message-ID: <49942364.7080607@trash.net>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net> <4990C337.3040704@netfilter.org> <4991863F.3030800@trash.net> <4991CCC1.7080308@netfilter.org> <4992C827.20302@trash.net> <4992FF51.9010507@netfilter.org> <499302E0.4070406@trash.net> <49933CBE.8010108@netfilter.org> <4993AE94.1000104@trash.net> <499417E3.5010304@netfilter.org> <499418F2.8070008@netfilter.org> <49941A89.80606@trash.net> <4994220F.7050603@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4994220F.7050603@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> Pablo Neira Ayuso wrote:
>>> Oh, and also for this:
>>>
>>>>     if (p->skb2 == NULL) {
>>>>         netlink_overrun(sk);
>>>>         /* Clone failed. Notify ALL listeners. */
>>>>         p->failure = 1;
>>>                 ^^^^^^^^^^^^^^^
>>>
>>> if (nlk->flags & NETLINK_HIGHLY_RELIABLE)
>>>     p->failure = 1;
>> I always wondered about the intention behind this. It wouldn't
>> hurt to just try the other allocation and see if they also fail.
> 
> Indeed. I don't see either the point of stopping other sockets from
> receiving the message because one clone failed, but that's a different
> issue I think.

Indeed.

> BTW, the netlink_set_err() function (I found one call in rtnetlink.c)
> also attracted my attention since it sets the EAGAIN error to all
> listeners when nlmsg_multicast() fails, which happens if the echoing is
> set and unicast fails. This made me think, what would it be the action
> taken by the multicast userspace listener if it hits EAGAIN? Probably,
> let them know that this request may retry? I think there's nothing they
> can do anyway.

They can resync. Not sure where you're getting EAGAIN from, its usually
used to deliver ENOBUFS to sockets when the kernel failed to even
allocate the first skb thats cloned to the sockets. Check out rtmsg_ifa
for an example.

