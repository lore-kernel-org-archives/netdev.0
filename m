From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/7] Allow to monitor multicast cache event via rtnetlink
Date: Wed, 5 Dec 2012 11:41:33 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70DA@saturn3.aculab.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com> <20121204.130914.1457976839967676240.davem@davemloft.net> <50BE56D3.2030704@6wind.com> <50BF29DA.7020903@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <nicolas.dichtel@6wind.com>, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58508 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751674Ab2LELtS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 06:49:18 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22359-06 for <netdev@vger.kernel.org>;
 Wed,  5 Dec 2012 11:49:14 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <50BF29DA.7020903@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> The one thing I worry about are those 64-bit statistics.  I fear that they
> >> not be 64-bit aligned in the final netlink message.  This matters on cpus
> >> that trap on unaligned loads/stores, such as sparc and MIPS.
> >>
> >> Can you validate this?
> >>
> > I can have a try on a tile platform. I don't have access to sparc or mips.

> Hmm, I've read arm instead of mips! So I've tried on mips. Data are aligned on
> 32-bit, like for all netlink messages. nla_put_u64() will do the same, as it
> calls nla_put().
> 
> And the kernel will only use memcpy() to treat this attribute. Reader will be in
> userland.

Probably worth commenting that the 64bit items might only be 32bit aligned.
Just to stop anyone trying to read/write them with pointer casts.

I think they are currently done with memcpy() - which should be ok.
It might be possibly to optimise by using a structure containing
a 64bit value marked __attribute__((aligned(4))).

	David
