From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 01/01] ipv6: RFC4214 Support (v2.0)
Date: Tue, 13 Nov 2007 09:29:51 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC28@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC14@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC1F@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC22@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC24@XCH-NW-7V2.nw.nos.boeing.com> <4739C7EA.5070609@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC27@XCH-NW-7V2.nw.nos.boeing.com> <4739D7F7.90300@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	=?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:64457 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425AbXKMR37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 12:29:59 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4739D7F7.90300@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad, 

> -----Original Message-----
> From: Vlad Yasevich [mailto:vladislav.yasevich@hp.com] 
> Sent: Tuesday, November 13, 2007 9:00 AM
> To: Templin, Fred L
> Cc: netdev@vger.kernel.org; YOSHIFUJI Hideaki / 吉藤英明
> Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.0)
> 
> Hi Fred
> 
> Templin, Fred L wrote: 
> >>> +		return;
> >>> +	}
> >>> +
> >>>  	sit_add_v4_addrs(idev);
> >>>  
> >>>  	if (dev->flags&IFF_POINTOPOINT) {
> >>> @@ -2531,6 +2570,18 @@ static void addrconf_rs_timer(unsigned l
> >>>  		 *	Announcement received after solicitation
> >>>  		 *	was sent
> >>>  		 */
> >>> +
> >>> +		/* ISATAP (RFC4214) - schedule next RS/RA */
> >>> +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
> >>> +			struct ip_tunnel *t  = 
> >> netdev_priv(ifp->idev->dev);
> >>> +			if (t->parms.i_key != INADDR_NONE) {
> >>> +				spin_lock(&ifp->lock);
> >>> +				ifp->probes = 0;
> >>> +				ifp->idev->if_flags &= 
> >> ~(IF_RS_SENT|IF_RA_RCVD);
> >>> +				addrconf_mod_timer(ifp, AC_DAD, 
> >> t->parms.o_key*HZ);
> >>
> >> You are using a DAD timer to schedule RS?
> > 
> > I am using the DAD timer to re-DAD the link local, which
> > in turn schedules RS.
> > 
> 
> Why?  Seems to me that using the RS timer (AC_RS) gets you 
> everything you
> want and nothing you don't.  You set probes to 0, which marks 
> DAD complete,
> thus you don't do DAD.  You already have code in the 
> addrconf_rs_timer() to
> properly send the RS.  So, your patch to sending the RS is 
> much shorter if
> you use the AC_RS timer.
> 
> Am I missing something?

Probably not. "Re-DAD the link-local" just seemed to have a nice
ring about it, but if we don't need it we can just as well go straight
to the RS. I'll take a closer look to verify...

Thanks - Fred
fred.l.templin@boeing.com
