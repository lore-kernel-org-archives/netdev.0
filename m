From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 04/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 10:41:49 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF3@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com> <20071108.033650.113099372.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:54080 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbXKGSmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 13:42:01 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071108.033650.113099372.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yoshifuji, 

> -----Original Message-----
> From: YOSHIFUJI Hideaki / 吉藤英明 [mailto:yoshfuji@linux-ipv6.org] 
> Sent: Wednesday, November 07, 2007 10:37 AM
> To: Templin, Fred L
> Cc: netdev@vger.kernel.org; yoshfuji@linux-ipv6.org
> Subject: Re: [PATCH 04/05] ipv6: RFC4214 Support
> 
> Hello.
> 
> In article 
> <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.bo
> eing.com> (at Tue, 6 Nov 2007 17:16:11 -0800), "Templin, Fred 
> L" <Fred.L.Templin@boeing.com> says:
> 
> > @@ -154,6 +155,14 @@ static struct ip_tunnel * ipip6_tunnel_l
> >  	struct net_device *dev;
> >  	char name[IFNAMSIZ];
> >  
> > +#if defined(CONFIG_IPV6_ISATAP)
> > +	/* ISATAP (RFC4214) - router address in daddr */
> > +	if (!strncmp(parms->name, "isatap", 6)) {
> > +		parms->i_key = parms->iph.daddr;
> > +		parms->iph.daddr = remote = 0;
> > +	}
> > +#endif
> > +
> >  	for (tp = __ipip6_bucket(parms); (t = *tp) != NULL; tp =
> > &t->next) {
> >  		if (local == t->parms.iph.saddr && remote ==
> > t->parms.iph.daddr)
> >  			return t;
> 
> I do not think it is a good idea to change the behavior based on
> the interface name.

The goal was to avoid requiring changes to applications such as
'iproute2', i.e., the intention was for a standalone code insertion point
within the kernel itself. What do you suggest?

> > @@ -182,6 +191,11 @@ static struct ip_tunnel * ipip6_tunnel_l
> >  	dev->init = ipip6_tunnel_init;
> >  	nt->parms = *parms;
> >  
> > +#if defined(CONFIG_IPV6_ISATAP)
> > +	if (!strncmp(dev->name, "isatap", 6))
> > +		dev->priv_flags |= IFF_ISATAP;
> > +#endif
> > +
> 
> ditto.

Same as above, but note that the name check is confined to these
two places.

> 
> > +		    if (!(ipv6_addr_is_isatap(addr6)) ||
> > +			(addr6->s6_addr32[3] != iph->saddr)) {
> > +drop:
> > +			tunnel->stat.rx_errors++;
> 
> you can unlock here.

OK; will fix.

Fred
fred.l.templin@boeing.com

> > +			dst_release(dst);
> > +			kfree_skb(skb);
> > +			read_unlock(&ipip6_lock);
> > +			return 0;
> > +		    }
> > +		    dst_release(dst);
> > +		}
> > +accept:
> > +#endif
> 
> --yoshfuji
> 
