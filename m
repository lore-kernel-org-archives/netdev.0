From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in absence of MSS option
Date: Tue, 11 Jun 2013 16:00:06 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7285@saturn3.aculab.com>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org> <1370880461-4265-4-git-send-email-pablo@netfilter.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7282@saturn3.aculab.com> <20130610071954.GA13500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Pablo Neira Ayuso" <pablo@netfilter.org>,
	<netfilter-devel@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: "Phil Oester" <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51810 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753803Ab3FKPAU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 11:00:20 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21231-04 for <netdev@vger.kernel.org>;
 Tue, 11 Jun 2013 16:00:16 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130610071954.GA13500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, Jun 11, 2013 at 09:43:07AM +0100, David Laight wrote:
> > Is setting the mss to 536 actually ever sensible?
> > RFC 879 might say that it is the default (and the minimum
> > that must be supported), but in practise the actual mss
> > is very likely to be only slightly shorter than the standard
> > ethernet mss.
> > Although strict conformance with RFC 879 might require the mss
> > be clamped to 536, pragmatically a value much nearer 1400 would
> > make sense - systems with very low mtu/mss are probably likely
> > to advertise it.
> 
> Read the associated bugzilla - there was at least one real world
> example where setting a higher MSS was causing breakage.
> 
> Phil
> 
> https://bugzilla.netfilter.org/show_bug.cgi?id=662

To quote that bug:

I stumbled upon this problem in debian bug #541658[1] ("[iceweasel] cannot open 
research.microsoft.com" - only worth reading for entertainment purposes) and,
after that bug was closed, analysed it in my blog[2] until a friend of mine
found out why the page loads when clamping mss to pmtu is disabled or
restricted to a range (like with "iptables -A FORWARD -p tcp --tcp-flags
SYN,RST SYN -m tcpmss --mss 1400:1536 -j TCPMSS --clamp-mss-to-pmtu") but
doesn't load with "simple" clamping. His really great and detailed analysation
of the problem may be seen at [3].

If I read/understand that correctly, clamping to 1400 worked - there was
no need to clamp all the way down to 536.

	David
