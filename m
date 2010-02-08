From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC]: xfrm by mark
Date: Mon, 08 Feb 2010 14:30:44 +0100
Message-ID: <4B701204.6000106@trash.net>
References: <1265567522.3688.27.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	=?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34418 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700Ab0BHNar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 08:30:47 -0500
In-Reply-To: <1265567522.3688.27.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> Hi,
> 
> While catching up with old netdev threads I noticed this one:
> http://marc.info/?l=linux-netdev&m=125621829709171&w=2
> I had a chat with Timo and he is too busy on other things at
> the moment. I have some cycles to burn and would like to pursue
> this unless there is objection to the general idea. I am interested
> because I would like to see most of the net stack capable of 
> reference by mark. I am posting this so i can get a general
> pulse before i go off coding.
> 
> Approach:
> - introduce attribute XFRMA_MARK
> - both SPD and SAD will have new entries ->mark
> - by default mark is 0, so backward compat for 
> control add/get/del as well as fast path lookup continues.

If you simply add the mark to the lookup key, it will break
existing setups already using marks. I'd suggest to also add
a mask which is initialized to 0 when no mark attribute is
present.
