From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: ipv6: put host and anycast routes on device with address
Date: Fri, 18 Aug 2017 19:15:31 -0400
Message-ID: <87wp60lb70.fsf@stressinduktion.org>
References: <1502997440-32334-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36895 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751060AbdHRXPd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:15:33 -0400
In-Reply-To: <1502997440-32334-1-git-send-email-dsahern@gmail.com> (David
        Ahern's message of "Thu, 17 Aug 2017 12:17:20 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

David Ahern <dsahern@gmail.com> writes:

> @@ -2688,15 +2716,9 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>  {
>  	u32 tb_id;
>  	struct net *net = dev_net(idev->dev);
> -	struct net_device *dev = net->loopback_dev;
> +	struct net_device *dev = idev->dev;
>  	struct rt6_info *rt;
>  
> -	/* use L3 Master device as loopback for host routes if device
> -	 * is enslaved and address is not link local or multicast
> -	 */
> -	if (!rt6_need_strict(addr))
> -		dev = l3mdev_master_dev_rcu(idev->dev) ? : dev;
> -
>  	rt = ip6_dst_alloc(net, dev, DST_NOCOUNT);
>  	if (!rt)
>  		return ERR_PTR(-ENOMEM);

I am afraid this change might break Java:

<http://hg.openjdk.java.net/jdk9/jdk9/jdk/file/65464a307408/src/java.base/unix/native/libnet/net_util_md.c#l574>

I am all in for this change, but maybe it might be necessary to mask
RTF_LOCAL routes with "lo" somehow.

Bye,
Hannes
