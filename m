From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Premature timeout for MLDv1 Host compatibility mode?
Date: Thu, 2 Aug 2012 08:58:54 -0400
Message-ID: <OFB6FB6105.8DE1252A-ON85257A4E.004637D4-85257A4E.00474EEF@us.ibm.com>
References: <CAOLNa-dCpLG4XCarzbSb=ptu-KGVX_Fghv4Z_CDQ8HBF_n-rGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Dragos Ilie <dragos.ilie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:34532 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807Ab2HBM7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 08:59:05 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 2 Aug 2012 08:59:04 -0400
In-Reply-To: <CAOLNa-dCpLG4XCarzbSb=ptu-KGVX_Fghv4Z_CDQ8HBF_n-rGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 07/26/2012 10:57:43 AM:

> RFC 3810 says that the timeout should be computed as
> Robustness_Variable * Query_Interval + Query_Response_Interval. This
> suggests that the line where switchback is computed should be changed
> to something like
> 
> switchback = (idev->mc_qrv * 125 * HZ)  + max_delay;
> 
> where 125 is the default Query_Interval in seconds

Dragos,
        I agree that it's too short, but this shouldn't be using the
default value, but rather the actual value of the querier, if one is 
present,
as calculated from a QQIC in a query. I suggest saving the QQI,
decoded, in a new "idev->mc_qqi" which should be initialized to 125
but updated by received queries and then using:

switchback = idev->mc_qrv * idev->mc_qqi * HZ + max_delay;

                                                +-DLS
