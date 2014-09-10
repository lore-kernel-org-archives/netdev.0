From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: 3.17-rc1 oops during network interface configuration
Date: Wed, 10 Sep 2014 13:04:41 -0700 (PDT)
Message-ID: <20140910.130441.1068300156073509217.davem@davemloft.net>
References: <53F47917.8080003@mellanox.com>
	<F580F466-28A5-4BDD-A338-D5C065A760C1@oracle.com>
	<541000F1.5000805@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, _govind-KK0ffGbhmjU@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bvanassche-HInyCGIudOg@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <541000F1.5000805-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Wed, 10 Sep 2014 10:42:41 +0300

> Hi Chuck, thanks for bisecting this out. Indeed, as of this kernel 3.2
> commit 936d7de "IPoIB: Stop lying about hard_header_len and use
> skb->cb to stash LL addresses" we are using the skb->cb field to
> enable proper work under GRO and avoid another historical quirk we had
> there... so I think we can definetly consider commit e0f31d849 to
> introduce a severe regression... Govindarajulu, Dave - what's your
> thinking here? any quick idea on how to fix?

Eric mentioned that we could reduce the amount of flow state stored
in the qdisc cb in order to handle this better.

Making skb->cb[] larger is basically out of the question as far as
I'm concerned.

> Also, I was thinking we have the mechanics in the kernel, e.g commit
> a0417fa3a18a ("net: Make qdisc_skb_cb upper size bound explicit.") to
> catch such over-flows?

Yes we should have added a build-time check so that we would discover
this issue more quickly.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
