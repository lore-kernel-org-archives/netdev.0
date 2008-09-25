From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: NBMA GRE over IPsec behind NAT
Date: Thu, 25 Sep 2008 10:51:32 +0300
Message-ID: <48DB4304.4050801@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:45557 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbYIYHvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 03:51:40 -0400
Received: by ey-out-2122.google.com with SMTP id 6so96469eyi.37
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 00:51:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been working on OpenNHRP (http://opennhrp.sf.net) to get Cisco DMVPN
support for Linux boxes. Basically it is NBMA GRE over IPsec. And the GRE
level private IP-public IP mapping is done via NHRP protocol. OpenNHRP does
this by talking to kernel neighbor cache.

I haven't still bumped into this problem (and probably won't for a while),
but it'd be good to solve it anyway. The problem is that, if I have multiple
IPsec nodes behind same NAT box, that is both have same public-ip, but
different NAT original address, the NHRP private ip to public ip mapping is
not enough. Since NHRP knows the NAT-OA it could indicate that back to kernel
to the neighbor cache. ip_gre could then pass that information to xfrm layer
which could using that decide the correct IPsec SA to use.

Now trying to figure out how this should be done. Maybe a new attribute to
neighbor cache message? Or give both IP addresses in the NDA_LLADDR
attribute? And how could ip_gre pass that info to xfrm? Or maybe IP gre
would not have to be touched, just make xfrm get the extra info from
neighbor cache?

Thanks,
  Timo
