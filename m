From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [PATCH v2 net-next] bridge: Add ability to enable TSO
Date: Fri, 9 Jan 2015 14:10:13 -0500 (EST)
Message-ID: <1077735415.7059200.1420830613699.JavaMail.zimbra@redhat.com>
References: <1420780600-11313-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1138400428.6686751.1420782286490.JavaMail.zimbra@redhat.com> <54AF73AD.4000008@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6-phx2.redhat.com ([209.132.183.39]:42276 "EHLO
	mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbbAITKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 14:10:19 -0500
In-Reply-To: <54AF73AD.4000008@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > 
> >>
> >> Currently a bridge device turns off TSO feature if no bridge ports
> >> support it. We can always enable it, since packets can be segmented on
> >> ports by software as well as on the bridge device.
> >> This will reduce the number of packets processed in the bridge.
> >>
> >> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> >> ---
> >> v2: Use an existing helper function.
> >>
> >>  net/bridge/br_if.c | 1 +
> >>  1 file changed, 1 insertion(+)
> >>
> >> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> >> index ed307db..81e49fb 100644
> >> --- a/net/bridge/br_if.c
> >> +++ b/net/bridge/br_if.c
> >> @@ -424,6 +424,7 @@ netdev_features_t br_features_recompute(struct
> >> net_bridge
> >> *br,
> >>  		features = netdev_increment_features(features,
> >>  						     p->dev->features, mask);
> >>  	}
> >> +	features = netdev_add_tso_features(features, mask);
> > 
> > Just a doubt. Are we inducing latency if source has traffic at very low
> > rate.
> > I mean by default do we need it?
> 
> Is your concern tcp_tso_should_defer() in tcp_write_xmit()?
yes.

> If so, since TSO packet is created by GSO even without this patch, this
> should not increase latency there.
> This patch just delays the point of software segmentation from the
> bridge device to its port.

I think now I got your point. 

Thanks,
Pankaj
> 
> Thanks,
> Toshiaki Makita
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
