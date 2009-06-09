From: Patrick McHardy <kaber@trash.net>
Subject: Re: error handling for dev_mc_sync (__dev_addr_add)
Date: Tue, 09 Jun 2009 19:10:55 +0200
Message-ID: <4A2E979F.9090407@trash.net>
References: <1244556667.4672.18.camel@johannes.local>	 <4A2E7376.4080407@trash.net> <1244558606.4672.25.camel@johannes.local>	 <4A2E7929.9070705@trash.net> <1244567063.18481.13.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34667 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbZFIRKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 13:10:55 -0400
In-Reply-To: <1244567063.18481.13.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> On Tue, 2009-06-09 at 17:00 +0200, Patrick McHardy wrote:
> 
>>> Regular drivers should need to be changed,
>>> would they, except for adding changing 'return' to 'return 0;' and
>>> adding a 'return 0;' at the end which is a quite simple spatch I'd
>>> think.
>> Right.
> 
> Yeah, so this spatch should be sufficient:
> 
> ----- >% -----
> @ ndomatch @
> identifier ndo, sml;
> @@
> struct net_device_ops ndo = {
> .ndo_set_multicast_list = sml,
> };
> @forall@
> identifier dev;
> identifier ndomatch.sml;
> @@
> void sml(struct net_device *dev)

- void
+ int

> {
> ...
> -return;
> +return 0;
> ...
> }
> ----- %< -----
> 
> Haven't really tested it though but it seems to do the correct thing for
> all drivers I looked at.

In case this also adds a return statement at the end if none is
there already, it looks fine.

