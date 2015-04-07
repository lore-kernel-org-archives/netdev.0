From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] netfilter: Pass socket pointer down through okfn().
Date: Tue, 07 Apr 2015 12:01:22 -0400 (EDT)
Message-ID: <20150407.120122.1683603489877737371.davem@davemloft.net>
References: <20150405.221904.606225054570296194.davem@davemloft.net>
	<1428417869.2928.1.camel@stressinduktion.org>
	<20150407153533.GA3979@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jiri@resnulli.us
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150407153533.GA3979@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 7 Apr 2015 17:35:33 +0200

> On Tue, Apr 07, 2015 at 04:44:29PM +0200, Hannes Frederic Sowa wrote:
>> On So, 2015-04-05 at 22:19 -0400, David Miller wrote:
>> > --- a/include/linux/netfilter.h
>> > +++ b/include/linux/netfilter.h
>> > @@ -54,7 +54,7 @@ struct nf_hook_state {
>> >  	struct net_device *in;
>> >  	struct net_device *out;
>> >  	struct sock *sk;
>> > -	int (*okfn)(struct sk_buff *);
>> > +	int (*okfn)(struct sock *, struct sk_buff *);
>> >  };
>> 
>> If we give okfn the signature int (*okfn)(struct nf_hook_state *); then
>> we would not need to touch anything else to enhance this.
>> 
>> What do you think?
> 
> I guess you mean something like:
> 
>         int (*okfn)(struct sk_buff *, struct nf_hook_state *);
> 
> I agree that would save us from more changes on the okfn() signature.
> I think it's OK if that change is introduced once we have some client
> code that needs it, I mean in a follow up patch.

No, becuase this means things like ip_finish_output(), and even
generic functions like dst_output(), dev_loopback_xmit(), and friends
will have netfilter specific arguments, and that is not acceptable.

Please do not suggest this.
