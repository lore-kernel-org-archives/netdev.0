From: "John Que" <qwejohn@gmail.com>
Subject: Re: time stamps of skb packets in NF_HOOKS callbacks
Date: Fri, 18 Aug 2006 08:43:08 +0300
Message-ID: <ada605fb0608172243raeff154q728bdd026b5b1d31@mail.gmail.com>
References: <ada605fb0608170737m4c0096c4u33a70dcf37e09df8@mail.gmail.com>
	 <20060817155835.GA11898@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:36948 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964804AbWHRFnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 01:43:09 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1183142nfa
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2006 22:43:08 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060817155835.GA11898@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,
Sorry ! ; last sentence in my reply was chopped so here is my message
again with this last sentence (complete this time)

Thnks, I appreciate your (quick) answer;


Following your answer I tried adding a call to net_enable_timestamp() in
a module I wrote which use NF_HOOKS.
This is what is done , for example, in ipq_rcv_skb(struct sk_buff *skb)
in linux-2.6.14 in net/ipv4/netfilter/ip_queue.c.

After doing so I get timestamps which are not 0.

what I wonder now is :
1) does this have ANY performance implication (when dealing with a
high  network  load which can get to 50,000 packets per second?
2) It does work as I said, but I want to be cautios: Am I permitted to
add this method ? are  there any  implications for adding this method
which can create troubles ?
I must say that I am NOT changing anywhere the timestamp; it's only
for statistics.

Regards,
John




On 8/17/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Thu, Aug 17, 2006 at 05:37:15PM +0300, John Que (qwejohn@gmail.com) wrote:
> > Hello,
> > I am using NF_HOOKS (a "PRE_ROUTING" hook).
> > When I try to print the time stamps (sec and usec) of skb packets
> > which I recieve
> > in the hook callback I get 0. Other skb fileds are correct.
> > According to my understanding, the time stamp should be updated
> > when the packet is received. Isn't it so ? Any idea why am I getting
> > "0" for tstamp fields (tstamp is a field in sk_buff and is  an intance
> > of skb_timeval).
>
> Timestamps are disabled by default, if you have sockets which enable
> SO_TIMESTAMP or netfilter queue target and other agents which can enable
> it, you will see updated values in skb->tstamp.
>
> --
>         Evgeniy Polyakov
>
