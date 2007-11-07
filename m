From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 04/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 11:12:47 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF5@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com><20071108.033650.113099372.yoshfuji@linux-ipv6.org><39C363776A4E8C4A94691D2BD9D1C9A1029EDBF3@XCH-NW-7V2.nw.nos.boeing.com> <20071107104524.2bd738cb@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>, <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:51267 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658AbXKGTNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 14:13:45 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071107104524.2bd738cb@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@linux-foundation.org] 
> Sent: Wednesday, November 07, 2007 10:45 AM
> To: Templin, Fred L
> Cc: YOSHIFUJI Hideaki / 吉藤英明; netdev@vger.kernel.org
> Subject: Re: [PATCH 04/05] ipv6: RFC4214 Support
> 
> On Wed, 7 Nov 2007 10:41:49 -0800
> "Templin, Fred L" <Fred.L.Templin@boeing.com> wrote:
> 
> > Yoshifuji, 
> > 
> > > -----Original Message-----
> > > From: YOSHIFUJI Hideaki / 吉藤英明 [mailto:yoshfuji@linux-ipv6.org] 
> > > Sent: Wednesday, November 07, 2007 10:37 AM
> > > To: Templin, Fred L
> > > Cc: netdev@vger.kernel.org; yoshfuji@linux-ipv6.org
> > > Subject: Re: [PATCH 04/05] ipv6: RFC4214 Support
> > > 
> > > Hello.
> > > 
> > > In article 
> > > <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.bo
> > > eing.com> (at Tue, 6 Nov 2007 17:16:11 -0800), "Templin, Fred 
> > > L" <Fred.L.Templin@boeing.com> says:
> > > 
> > > > @@ -154,6 +155,14 @@ static struct ip_tunnel * ipip6_tunnel_l
> > > >  	struct net_device *dev;
> > > >  	char name[IFNAMSIZ];
> > > >  
> > > > +#if defined(CONFIG_IPV6_ISATAP)
> > > > +	/* ISATAP (RFC4214) - router address in daddr */
> > > > +	if (!strncmp(parms->name, "isatap", 6)) {
> > > > +		parms->i_key = parms->iph.daddr;
> > > > +		parms->iph.daddr = remote = 0;
> > > > +	}
> > > > +#endif
> > > > +
> > > >  	for (tp = __ipip6_bucket(parms); (t = *tp) != NULL; tp =
> > > > &t->next) {
> > > >  		if (local == t->parms.iph.saddr && remote ==
> > > > t->parms.iph.daddr)
> > > >  			return t;
> > > 
> > > I do not think it is a good idea to change the behavior based on
> > > the interface name.
> > 
> > The goal was to avoid requiring changes to applications such as
> > 'iproute2', i.e., the intention was for a standalone code 
> insertion point
> > within the kernel itself. What do you suggest?
> 
> Agreed, magic names are evil.
> 
> Change iproute2 utilities, if it is more logical for administration.

This being an experimental release, I would prefer to go
forward with a standalone kernel solution for the first
iteration then come back with the iproute2 changes at a
later time. IMHO, we should only touch iproute2 once, and
it should be an architected solution - not just a quick
hack. For the short term, timeliness of interoperability testing
with the other major OS's should be the highest priority, IMHO.

Other opinions?

Fred
fred.l.templin@boeing.com
