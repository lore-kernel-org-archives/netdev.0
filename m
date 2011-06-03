From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] Use unsigned variables for packet lengths in ip[6]_queue.
Date: Fri, 03 Jun 2011 12:07:37 +0200
Message-ID: <4DE8B269.9070505@netfilter.org>
References: <20110420014221.GC26949@redhat.com> <20110419.204105.68144653.davem@davemloft.net> <20110528003651.GA8380@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110528003651.GA8380@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/05/11 02:36, Dave Jones wrote:
> On Tue, Apr 19, 2011 at 08:41:05PM -0700, David Miller wrote:
>  > From: Dave Jones <davej@redhat.com>
>  > Date: Tue, 19 Apr 2011 21:42:22 -0400
>  > 
>  > > Not catastrophic, but ipqueue seems to be too trusting of what it gets
>  > > passed from userspace, and passes it on down to the page allocator,
>  > > where it will spew warnings if the page order is too high.
>  > > 
>  > > __ipq_rcv_skb has several checks for lengths too small, but doesn't
>  > > seem to have any for oversized ones.   I'm not sure what the maximum
>  > > we should check for is. I'll code up a diff if anyone has any ideas
>  > > on a sane maximum.
>  > 
>  > Maybe the thing to do is to simply pass __GFP_NOWARN to nlmsg_new()
>  > in netlink_ack()?
>  > 
>  > Anyone else have a better idea?
> 
> So I went back to this today, and found something that doesn't look right.
> After adding some instrumentation, and re-running my tests, I found that
> the reason we were blowing up with enormous allocations was that we
> were passing down a nlmsglen's like -1061109568
> 
> Is there any reason for that to be signed ?
> The nlmsg_len entry of nlmsghdr is a u32, so I'm assuming this is a bug.
> 
> With the patch below, I haven't been able to reproduce the problem, but
> I don't know if I've inadvertantly broken some other behaviour somewhere
> deeper in netlink where this is valid.

I have applied this. Thanks.

BTW, ip[6]_queue has been marked obsoleted since long time, probably we
can schedule this for removal anytime soon. The nfnetlink_queue
successor has been there to provide a replacement for this since long time.
