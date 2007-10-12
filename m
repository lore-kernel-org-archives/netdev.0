From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Fri, 12 Oct 2007 20:29:49 +0200
Message-ID: <20071012182949.GB12933@one.firstfloor.org>
References: <20071010003716.GB552@one.firstfloor.org> <36D9DB17C6DE9E40B059440DB8D95F5203887DD1@orsmsx418.amr.corp.intel.com> <20071012100500.02255243@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	jeff@garzik.org, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com, kaber@trash.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41268 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851AbXJLS3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 14:29:51 -0400
Content-Disposition: inline
In-Reply-To: <20071012100500.02255243@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Use RCU? or write a generic version and get it reviewed.  You really
> want someone with knowledge of all the possible barrier impacts to
> review it.

I guess he was thinking of using cmpxchg; but we don't support this
in portable code.

RCU is not really suitable for this because it assume
writing is relatively rare which is definitely not the case for a qdisc.
Also general list management with RCU is quite expensive anyways --
it would require a full copy (that is the 'C' in RCU which Linux
generally doesn't use at all) 

-Andi
