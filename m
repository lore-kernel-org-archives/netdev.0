From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Premature timeout for MLDv1 Host compatibility mode?
Date: Thu, 2 Aug 2012 09:57:57 -0400
Message-ID: <OF675087EF.EDC93ADE-ON85257A4E.004B2D96-85257A4E.004CB6BE@us.ibm.com>
References: <CAOLNa-dCpLG4XCarzbSb=ptu-KGVX_Fghv4Z_CDQ8HBF_n-rGQ@mail.gmail.com>	<OFB6FB6105.8DE1252A-ON85257A4E.004637D4-85257A4E.00474EEF@us.ibm.com> <CAOLNa-dj1N-3Lo6Bu8X4H51gxBs4B2V0qWSDFQ-2qQzjEApJfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Dragos Ilie <dragos.ilie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:53702 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab2HBN6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 09:58:55 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 2 Aug 2012 07:58:50 -0600
In-Reply-To: <CAOLNa-dj1N-3Lo6Bu8X4H51gxBs4B2V0qWSDFQ-2qQzjEApJfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dragos Ilie <dragos.ilie@gmail.com> wrote on 08/02/2012 09:28:49 AM:
 
> MLDv1 packets do not have a QQIC field in the Query header. That is a
> available for MLDv2 only. Consequently, MLDv1 queriers should fallback
>  on the Query Interval variable, which has a  default value of 125
> seconds. Since the Query Interval value is not user-configurable, I
> assume that using the default value is a reasonable choice.

The QQIC would come from v2 queries prior to the v1 query that
triggered us to switch to v1. But, see below.
 
> RFC 3810(MLDv2)  does mention that the Older Version Querier Present
> Timeout must be calculated using the Query Interval from the last
> received Query. I think the RFC is wrong on that point because I don't
> see how a MLDv1 querier can convey its Query Interval to a listener.

I'll look through this some more. I think using a fixed timeout
is a bad idea since it doesn't account for shorter or longer interval
queriers intentionally configured that way. Ideally it should,
of course, be a positive indication that the v1 querier is gone
based on v1 querier data (your point).

                                                +-DLS
