From: Patrick McHardy <kaber@trash.net>
Subject: Re: VLAN GARP triggers a lot of timers if linux compiled with VLAN_8021Q_GVRP
Date: Wed, 29 Sep 2010 11:22:51 +0200
Message-ID: <4CA3056B.6010901@trash.net>
References: <AANLkTinZ_6+PzAHHc5vaY+H2iX_pf4vsdNsnZ2_N7EDf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: didier <did447@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53035 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442Ab0I2JXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 05:23:09 -0400
In-Reply-To: <AANLkTinZ_6+PzAHHc5vaY+H2iX_pf4vsdNsnZ2_N7EDf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 29.09.2010 02:35, schrieb didier:
> Hi,
> 
> In my understanding GARP is using a periodic timer but in net/802/garp.c:
> 
> garp_join_timer_arm()
> 
> delay = (u64)msecs_to_jiffies(garp_join_time)* net_random() >> 32;
> mod_timer(&app->join_timer, jiffies +delay)
> 
> Isn't this stuff triggering a *lot* of events?

Yeah, something around 5-10 timers per second IIRC. There was an RFC
patch a while ago to only schedule the timer on-demand, I'll see
whether I can find it again.
