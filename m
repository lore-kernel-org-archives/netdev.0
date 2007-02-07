From: Patrick McHardy <kaber@trash.net>
Subject: Re: Funny Routing change since 2.6.16.x
Date: Wed, 07 Feb 2007 18:18:42 +0100
Message-ID: <45CA09F2.6050700@trash.net>
References: <200702071756.34409.netdev@axxeo.de> <45CA0737.40308@trash.net> <200702071816.28235.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53766 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161391AbXBGRSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 12:18:46 -0500
In-Reply-To: <200702071816.28235.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> Patrick McHardy schrieb:
> 
>>My guess is that you're using MASQUERADE on ppp0, which since 2.6.14
>>doesn't exclude locally generated packets anymore, so it translates
>>them to the primary ppp0 address. For replies it works because NAT
>>is already set up for the incoming packet, without masquerading.
> 
> 
> Your guess is right! Thanks for that hint. Do you have any idea, how to
> restore the old behavior? 
> 
> I have to, because the ISP cannot assign a different local address
> and have problems with the new behavior, because that IP adress is an MX entry
> and the VPN gateway address for several third party vendor tunnels. 
> So changing that is quite an effort.


Since these packets already have the proper source address chosen
by routing, there is no need to NAT them anymore. So the easiest
fix is to exclude them manually from masquerading based on the
address.
