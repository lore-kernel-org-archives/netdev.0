From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Mon, 10 Feb 2014 21:37:12 -0800
Message-ID: <1392097032.6615.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
	 <20140211014535.GA11150@order.stressinduktion.org>
	 <CAHA+R7N2rxt5vyF+i8mi04dJaLk5bCgMAZOCexOLULLcQ-mT6w@mail.gmail.com>
	 <20140211024009.GD11150@order.stressinduktion.org>
	 <1392092120.6615.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7MhHuOPaT5oAF_S-a3u1_2mt=Vqd5HCdi9r3JV-fK-6Pw@mail.gmail.com>
	 <1392096087.6615.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:37720 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaBKFhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 00:37:13 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa1so7187457pad.13
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 21:37:13 -0800 (PST)
In-Reply-To: <1392096087.6615.72.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 21:21 -0800, Eric Dumazet wrote:
> On Mon, 2014-02-10 at 20:41 -0800, Cong Wang wrote:
> 
> > Exactly broken by design.
> 
> Design of what ? Do you have a pointer to a document about this
> 'design' ?
> 
> > 
> > IFA_LINK is an ifindex, ifindex is per-netns. macvlan should not use IFA_LINK.
> 
> When this was 'designed', ifindex were not per netns.
> 
> Apparently nobody spotted this when ifindexes become per netns.
> 
> I am sure we can find a solution, keeping this very useful
> functionality.

Simple patch would be :

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 048dc8d183aa..31bbba34fd1e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -963,6 +963,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_u32(skb, IFLA_NUM_RX_QUEUES, dev->num_rx_queues) ||
 #endif
 	    (dev->ifindex != dev->iflink &&
+	     __dev_get_by_index(dev_net(dev), dev->iflink) &&
 	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
 	    (upper_dev &&
 	     nla_put_u32(skb, IFLA_MASTER, upper_dev->ifindex)) ||
