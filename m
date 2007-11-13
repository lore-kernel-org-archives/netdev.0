From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.0)
Date: Tue, 13 Nov 2007 11:59:35 -0500
Message-ID: <4739D7F7.90300@hp.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC14@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC1F@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC22@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC24@XCH-NW-7V2.nw.nos.boeing.com> <4739C7EA.5070609@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC27@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SBsoQg==?=
	 =?ISO-2022-JP?B?GyRCRiMxUUxAGyhC?= <yoshfuji@linux-ipv6.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:58143 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466AbXKMQ7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 11:59:37 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC27@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fred

Templin, Fred L wrote: 
>>> +		return;
>>> +	}
>>> +
>>>  	sit_add_v4_addrs(idev);
>>>  
>>>  	if (dev->flags&IFF_POINTOPOINT) {
>>> @@ -2531,6 +2570,18 @@ static void addrconf_rs_timer(unsigned l
>>>  		 *	Announcement received after solicitation
>>>  		 *	was sent
>>>  		 */
>>> +
>>> +		/* ISATAP (RFC4214) - schedule next RS/RA */
>>> +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
>>> +			struct ip_tunnel *t  = 
>> netdev_priv(ifp->idev->dev);
>>> +			if (t->parms.i_key != INADDR_NONE) {
>>> +				spin_lock(&ifp->lock);
>>> +				ifp->probes = 0;
>>> +				ifp->idev->if_flags &= 
>> ~(IF_RS_SENT|IF_RA_RCVD);
>>> +				addrconf_mod_timer(ifp, AC_DAD, 
>> t->parms.o_key*HZ);
>>
>> You are using a DAD timer to schedule RS?
> 
> I am using the DAD timer to re-DAD the link local, which
> in turn schedules RS.
> 

Why?  Seems to me that using the RS timer (AC_RS) gets you everything you
want and nothing you don't.  You set probes to 0, which marks DAD complete,
thus you don't do DAD.  You already have code in the addrconf_rs_timer() to
properly send the RS.  So, your patch to sending the RS is much shorter if
you use the AC_RS timer.

Am I missing something?

Thanks
-vlad


