From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/4] ipv4: match prefsrc when deleting routes
Date: Tue, 22 Mar 2011 01:07:32 -0700 (PDT)
Message-ID: <20110322.010732.52188457.davem@davemloft.net>
References: <201103192213.p2JMDkuD003065@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755122Ab1CVIGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 04:06:54 -0400
In-Reply-To: <201103192213.p2JMDkuD003065@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 20 Mar 2011 00:13:46 +0200

> 	fib_table_delete forgets to match the routes by prefsrc.
> Callers can specify known IP in fc_prefsrc and we should remove
> the exact route. This is needed for cases when same local or
> broadcast addresses are used in different subnets and the
> routes differ only in prefsrc. All callers that do not provide
> fc_prefsrc will ignore the route prefsrc as before and will
> delete the first occurence. That is how the ip route del default
> magic works.
> 
> 	Current callers are:
> 
> - ip_rt_ioctl where rtentry_to_fib_config provides fc_prefsrc only
> when the provided device name matches IP label with colon.
> 
> - inet_rtm_delroute where RTA_PREFSRC is optional too
> 
> - fib_magic which deals with routes when deleting addresses
> and where the fc_prefsrc is always set with the primary IP
> for the concerned IFA.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied.
