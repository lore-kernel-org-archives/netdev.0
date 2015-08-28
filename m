From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/4] ip_tunnels: record IP version in tunnel
 info
Date: Fri, 28 Aug 2015 20:16:15 +0200
Message-ID: <20150828201615.0d148fbb@griffin>
References: <cover.1440771116.git.jbenc@redhat.com>
	<224503f4a3232da1664f1eca58b7bce87cfb3cc2.1440771116.git.jbenc@redhat.com>
	<CALnjE+og0n18p6_BwHfUudHDLPA5_WtT2TmqCM+FhGFtzj+FKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725AbbH1SQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 14:16:19 -0400
In-Reply-To: <CALnjE+og0n18p6_BwHfUudHDLPA5_WtT2TmqCM+FhGFtzj+FKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2015 10:32:15 -0700, Pravin Shelar wrote:
> > --- a/drivers/net/geneve.c
> > +++ b/drivers/net/geneve.c
> > @@ -644,6 +644,9 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
> >                 u8 *opts = NULL;
> >                 u8 vni[3];
> >
> > +               if (ip_tunnel_info_af(info) != AF_INET)
> > +                       goto err;
> > +
> geneve_get_rt() already interpreted the info as ipv4 tunnel info.

Hmm, okay. I'll move the check. The geneve module changed more than
I thought.

Thanks for noticing this.

> We can avoid such bugs by introducing separate API to retrieve ipv4
> and ipv6 tunnel info. Something like
> skb_tunnel_info_v4()/skb_tunnel_info_v6() for ipv4 and ipv6.

I don't think we want that. Ideally, the xmit function should work with
both and use the protocol information to choose the correct output
path. I intend to try this with the metadata based vxlan which would
use the correct socket (IPv4 or IPv6) appropriately. That way, we won't
need a separate vxlan interface for IPv4 and IPv6 traffic. Will be much
more user friendly and most likely easier to use from ovs, too.

 Jiri

-- 
Jiri Benc
