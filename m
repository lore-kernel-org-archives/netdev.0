From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in absence of MSS option
Date: Tue, 11 Jun 2013 17:09:11 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7286@saturn3.aculab.com>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org> <1370880461-4265-4-git-send-email-pablo@netfilter.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7282@saturn3.aculab.com> <20130610071954.GA13500@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7285@saturn3.aculab.com> <20130610082739.GA14277@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Pablo Neira Ayuso" <pablo@netfilter.org>,
	<netfilter-devel@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: "Phil Oester" <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54231 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754869Ab3FKQKQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 12:10:16 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02512-05 for <netdev@vger.kernel.org>;
 Tue, 11 Jun 2013 17:10:12 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130610082739.GA14277@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, Jun 11, 2013 at 04:00:06PM +0100, David Laight wrote:
> > To quote that bug:
> >
> > I stumbled upon this problem in debian bug #541658[1] ("[iceweasel] cannot open
> > research.microsoft.com" - only worth reading for entertainment purposes) and,
> > after that bug was closed, analysed it in my blog[2] until a friend of mine
> > found out why the page loads when clamping mss to pmtu is disabled or
> > restricted to a range (like with "iptables -A FORWARD -p tcp --tcp-flags
> > SYN,RST SYN -m tcpmss --mss 1400:1536 -j TCPMSS --clamp-mss-to-pmtu") but
> > doesn't load with "simple" clamping. His really great and detailed analysation
> > of the problem may be seen at [3].
> >
> > If I read/understand that correctly, clamping to 1400 worked - there was
> > no need to clamp all the way down to 536.
> 
> You are not understanding the issue correctly.  The reason the command worked with
> "-m tcpmss --mss 1400:1536" is because that implies an MSS option was provided.
> The issue occurs only when NO MSS option is sent.  In these cases, we cannot
> ASSUME that it is ok to use some arbitrarily high value (1400 as you propose).
> The RFC is clear on this point.

My problem is that I don't want TCP connections to drop the mss to
536 when talking to minimal/old implementations that don't add any
options to SYN packets.

	David
