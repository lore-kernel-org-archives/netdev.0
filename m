From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC 0/2] Interface for TCP Metrics
Date: Thu, 23 Aug 2012 19:26:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208231908380.28424@ja.ssi.bg>
References: <1345734105-28328-1-git-send-email-ja@ssi.bg> <20120823082235.27c057f6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51048 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752781Ab2HWQY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 12:24:28 -0400
In-Reply-To: <20120823082235.27c057f6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 23 Aug 2012, Stephen Hemminger wrote:

> Some of netlink API comments:
> 
> 1. My preference is to not make it so granular.
>    I.e make things like RTT a structure with value and variance
>    rather than lots of independent objects.

	Even the ip route used nested objects for metrics.
I preferred not to add fixed structure for them if that is
what you mean. I implemented it in the same way, just like
rtnetlink_put_metrics().

> 2. Make sure netlink API is symmetric. Get should report all
>    values and Set should accept the same values (but ignore
>    if value can not be modified).

	Will take care if one day we support SET request.

> 3. Try and make ip command output invertable, as in what you
>    print is close to what ip command arguments are.

	Any example for what you mean?

> 4. What about monitoring changes?

	I preferred to avoid them because if the routes
are small number and can be monitored, these entries are
modified very often and to me it looked overkill to generate
notification for every update just to notice that nobody
listens for it.

	BTW, I noticed that the GENL part in iproute is
not separated in common place. Should we create common
place for functions like genl_ctrl_resolve_family and
genl_parse_getfamily ?

	Thanks for the comments!

Regards

--
Julian Anastasov <ja@ssi.bg>
