From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 15:04:52 +0100
Message-ID: <200911171504.54170.mb@bu3sch.de>
References: <1258465585.3682.7.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Felix Fietkau <nbd@openwrt.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:43521 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752272AbZKQOEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 09:04:51 -0500
In-Reply-To: <1258465585.3682.7.camel@johannes.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 17 November 2009 14:46:25 Johannes Berg wrote:
> --- wireless-testing.orig/net/bridge/br_if.c	2009-11-17 14:19:17.000000000 +0100
> +++ wireless-testing/net/bridge/br_if.c	2009-11-17 14:20:03.000000000 +0100
> @@ -390,6 +390,10 @@ int br_add_if(struct net_bridge *br, str
>  	if (dev->br_port != NULL)
>  		return -EBUSY;
>  
> +	/* No bridging devices that dislike that (e.g. wireless) */
> +	if (dev->priv_flags & IFF_DONT_BRIDGE)
> +		return -EINVAL;

-EOPNOTSUPP?
That would probably produce a better error message in userspace.

-- 
Greetings, Michael.
