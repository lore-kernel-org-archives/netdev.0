From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH v7 1/2] net: implement mechanism for HW
 based QOS
Date: Thu, 13 Jan 2011 22:30:32 +0000
Message-ID: <1294957832.3946.61.camel@bwh-desktop>
References: <20110107224543.19830.74009.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jarkao2@gmail.com, hadi@cyberus.ca,
	eric.dumazet@gmail.com, shemminger@vyatta.com, tgraf@infradead.org,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6929 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149Ab1AMWag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 17:30:36 -0500
In-Reply-To: <20110107224543.19830.74009.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm actually having a go at implementing this, as a result of which I
have some more questions:

On Fri, 2011-01-07 at 14:45 -0800, John Fastabend wrote:
[...]
> With the mechanism in this patch users can set skb priority using
> expected methods ie setsockopt() or the stack can set the priority
> directly. Then the skb will be steered to the correct tx queues
> aligned with hardware QOS traffic classes. In the normal case with
> a single traffic class and all queues in this class everything
> works as is until the LLD enables multiple tcs.
> 
> To steer the skb we mask out the lower 4 bits of the priority
> and allow the hardware to configure upto 15 distinct classes
> of traffic. This is expected to be sufficient for most applications
> at any rate it is more then the 8021Q spec designates and is
> equal to the number of prio bands currently implemented in
> the default qdisc.

What is the meaning of a class number?  Is it simply higher number =>
higher priority?  If there are exactly 8 classes, can they be assumed to
match the 802.1q priority classes?

> This in conjunction with a userspace application such as
> lldpad can be used to implement 8021Q transmission selection
> algorithms one of these algorithms being the extended transmission
> selection algorithm currently being used for DCB.

Should an Ethernet driver/hardware insert a 802.1q priority tag if it
implements this, or should that be left to higher levels?

> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  include/linux/netdevice.h |   65 +++++++++++++++++++++++++++++++++++++++++++++
>  net/core/dev.c            |   61 ++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 125 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0f6b1c9..b1dbbed 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
[...]
> @@ -756,6 +764,7 @@ struct xps_dev_maps {
>   * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
>   *			  struct nlattr *port[]);
>   * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
> + * void (*ndo_setup_tc)(struct net_device *dev, u8 tc, unsigned int txq)
[...]

This is not documentation, it is just repetition!

Please specify what the parameters mean.  In particular, what is the
purpose of the txq parameter; can it be different from
dev->real_num_tx_queues?

Is this operation allowed to change the number of TX queues?  I was
looking at scaling the number of queues according to the number of
classes.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

