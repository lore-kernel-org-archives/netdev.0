From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 net-next 2/4] ip_tunnels: record IP version in tunnel
 info
Date: Sat, 29 Aug 2015 10:43:45 +0200
Message-ID: <20150829104345.4b7f031c@griffin>
References: <cover.1440787600.git.jbenc@redhat.com>
	<5f1807433565275c8bf699c0495b66c620b274c7.1440787600.git.jbenc@redhat.com>
	<20150828222411.GB32001@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33325 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbbH2Int (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2015 04:43:49 -0400
In-Reply-To: <20150828222411.GB32001@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Aug 2015 00:24:11 +0200, Thomas Graf wrote:
> On 08/28/15 at 08:48pm, Jiri Benc wrote:
> > diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> > index e2dc9dac59e6..40164037928e 100644
> > --- a/net/openvswitch/vport.c
> > +++ b/net/openvswitch/vport.c
> > @@ -587,6 +587,8 @@ int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
> >  
> >  	if (unlikely(!tun_info))
> >  		return -EINVAL;
> > +	if (ip_tunnel_info_af(tun_info) != AF_INET)
> > +		return -EINVAL;
> >  
> >  	tun_key = &tun_info->key;
> 
> Are you sure this chunk is needed? It looks like OVS_CB()->egress_tun_info
> can only be set via execute_set_action() which can only be of a supported
> AF type.

It does no harm and I'm going to add IPv6 tunneling support to ovs
soon. This is a nice reminder that this function is IPv4 only and needs
to be extended.

> Otherwise this looks great.
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Thanks!

 Jiri

-- 
Jiri Benc
