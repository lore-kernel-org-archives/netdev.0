From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 06 Feb 2012 14:56:52 -0500 (EST)
Message-ID: <20120206.145652.1575591691467905094.davem@davemloft.net>
References: <CAG4TOxNgJ3=AFuA==Km815YzW8eQ7nD_UAzkXLSXcAyaCAAvPg@mail.gmail.com>
	<20120206.143230.1415707004934341114.davem@davemloft.net>
	<20120206.145148.558736903670696169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120206.145148.558736903670696169.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Mon, 06 Feb 2012 14:51:48 -0500 (EST)

> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Date: Mon, 06 Feb 2012 14:32:30 -0500 (EST)
> 
>> From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> Date: Mon, 6 Feb 2012 11:23:21 -0800
>> 
>>> Does the netdev driver own skb->cb between hard_header
>>> and start_xmit?  If so we could use that instead of stealing
>>> some header space, and that would at least let us not lie
>>> about hard_header_len.
>> 
>> Unfortunately the packet scheduler sits between the hard_header()
>> call (via neigh_*_output() --> dev_hard_header()) and when the
>> device xmit method is invoked.
>> 
>> And the packet scheduler can make use of the skb->cb[], for
>> include/net/sch_generic.h:qdisc_skb_cb
> 
> Actually there is a way to make this work.
> 
> Define your ipoib_skb_cb something like:
> 
> struct ipoib_skb_cb {
> 	struct qdisc_skb_cb	qdisc_cb;
> 
> 	... ipoib stuff goes here ...
> };
> 
> That way you can use the SKB cb area for your ipoib info
> without interfering with the packet scheduler.

But this needs a little bit of work since the qdisc_skb_cb ends with a
variable length array, but we can put an upper bound on this just like
we do for skb->cb[] itself to fix this issue.

I'll toss something together.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
