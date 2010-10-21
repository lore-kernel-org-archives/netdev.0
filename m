From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Fri, 22 Oct 2010 01:56:51 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010220141440.3256@ja.ssi.bg>
References: <201010081317.04167.hans.schillstrom@ericsson.com> <20101021111644.GA25555@verge.net.au> <201010211342.42833.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Simon Horman <horms@verge.net.au>,
	"lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"wensong@linux-vs.org" <wensong@linux-vs.org>,
	"daniel.lezcano@free.fr" <daniel.lezcano@free.fr>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56621 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752454Ab0JUWz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 18:55:58 -0400
In-Reply-To: <201010211342.42833.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Thu, 21 Oct 2010, Hans Schillstrom wrote:

> static inline struct net * ipvs_devnet(struct skb *skb)
> {
> #ifdef CONFIG_NS_NET
> 	return dev_net(skb->dev);
> #else
> 	return init_net;
> #endif
> }

 	After last IPVS changes may be something like that
is needed instead:

static inline struct net *ipvs_skbnet(struct sk_buff *skb)
{
 	return dev_net(skb->dev ? : skb_dst(skb)->dev);
}

 	because now we have LOCAL_OUT processing.

Regards

--
Julian Anastasov <ja@ssi.bg>
