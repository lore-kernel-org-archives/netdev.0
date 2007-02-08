From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: Funny Routing change since 2.6.16.x
Date: Thu, 8 Feb 2007 16:52:31 +0100
Message-ID: <200702081652.31527.netdev@axxeo.de>
References: <200702071756.34409.netdev@axxeo.de> <200702071816.28235.netdev@axxeo.de> <45CA09F2.6050700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:4848 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423083AbXBHPwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 10:52:45 -0500
In-Reply-To: <45CA09F2.6050700@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Patrick McHardy schrieb:
> Ingo Oeser wrote:
> > Patrick McHardy schrieb:
> > 
> >>My guess is that you're using MASQUERADE on ppp0, which since 2.6.14
> >>doesn't exclude locally generated packets anymore, so it translates
> >>them to the primary ppp0 address. For replies it works because NAT
> >>is already set up for the incoming packet, without masquerading.
> > 
> > 
> > Your guess is right! Thanks for that hint. Do you have any idea, how to
> > restore the old behavior? 
> > 
> > I have to, because the ISP cannot assign a different local address
> > and have problems with the new behavior, because that IP adress is an MX entry
> > and the VPN gateway address for several third party vendor tunnels. 
> > So changing that is quite an effort.
> 
> 
> Since these packets already have the proper source address chosen
> by routing, there is no need to NAT them anymore. So the easiest
> fix is to exclude them manually from masquerading based on the
> address.

Just did that (iptables -t nat -I POSTROUTING -s $SRCADDR -o ppp0 -j ACCEPT)
and it works without any problems.

Many thanks for your very fast help! I'm very happy now :-)

Do you know any good place, where this can be documented?


Best regards

Ingo Oeser
