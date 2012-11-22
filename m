From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: 3.6 routing cache regression, multicast loopback broken
Date: Thu, 22 Nov 2012 15:04:16 +0100
Message-ID: <1353593056.8285.24.camel@sakura.staff.proxad.net>
References: <1352133471.12029.43.camel@sakura.staff.proxad.net>
	 <alpine.LFD.2.00.1211210055040.1751@ja.ssi.bg>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:38095 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756915Ab2KVT2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 14:28:31 -0500
In-Reply-To: <alpine.LFD.2.00.1211210055040.1751@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2012-11-21 at 02:35 +0200, Julian Anastasov wrote:

Hi,

> 	Do you also have CONFIG_IP_MROUTE enabled? I see the

I don't

> problem with caching both "RTCF_MULTICAST | RTCF_LOCAL" and
> "RTCF_MULTICAST" flags to same place but I'm not sure in the
> sequence of route lookups for your setup. ip_mc_output does
> not care about RTCF_LOCAL when CONFIG_IP_MROUTE is disabled,
> so in this case it should loop the packet even on wrong
> caching (without RTCF_LOCAL flag).

but the problem here was that dst was using ip_output() instead of
ip_mc_output().

> 	Can you try the following patch. If it does not
> solve the problem we have to add some debugs in __mkroute_output.
> And I'm not sure if this is fatal only when CONFIG_IP_MROUTE
> is enabled, I have to spend more time to check the code.
> As an optimization, the patch avoids lookup for fnhe
> when multicast is not cached because multicasts are
> not redirected and they do not learn PMTU.
> 
> 	The patch is not tested. I'll update the commit
> message after your tests.

the patch fixes the problem, and it looks valid to me.

thanks !

-- 
Maxime
