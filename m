From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: ip xfrm policy semantics
Date: Fri, 09 Jan 2009 16:16:30 +0200
Message-ID: <49675C3E.6010109@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:51501 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbZAIOQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 09:16:29 -0500
Received: by ewy10 with SMTP id 10so10235045ewy.13
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 06:16:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to setup a vpnc gateway device that is a part of Cisco DMVPN and also
generic NAT gateway to Internet.

The DMVPN part is achieved by a gre tunnel, which is protected by IPsec xfrm
policy.

So I want to encrypt all GRE traffic that is to/from the local box, thus I have:
src 0.0.0.0/0 dst 0.0.0.0/0 proto gre 
	dir in priority 2147483648 ptype main 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 0.0.0.0/0 dst 0.0.0.0/0 proto gre 
	dir out priority 2147483648 ptype main 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport

Which works perfect for the DMVPN part.

Now, I have a second device behind a subnet, that wants to talk to Internet
using PPTP (which ends up sending GRE packets). So what I want is that locally
generated / received packages should be protected by the ipsec policy. But
forwarded GRE packets (that are masqueraded) should not get any xfrm treatment.

It looks like that if xfrm out policy still affects the forwarded packets.
If I add an overriding policy for the PPTP server, things seem to work
better. But I'd rather not do that as it's a bit hacky.

I was not able to find any authoritative place how netfilter and xfrm policies
and routing interact. The only thing I found was [1], but that seems to be
inaccurate. Anyone care to shed light on this part?

Thanks,
  Timo

[1] http://www.strongswan.org/docs/netfilter.pdf

