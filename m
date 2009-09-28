From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 13/13] TProxy: use the interface primary IP address as
 a default value for --on-ip
Date: Mon, 28 Sep 2009 12:16:10 -0400
Message-ID: <4AC0E14A.10108@hp.com>
References: <1253548005.12519.13.camel@bzorp.balabit>	 <4AB7BF47.2030404@hp.com> <1253601509.6883.5.camel@bzorp.balabit>	 <4AB8DC6F.90602@hp.com> <1253902068.10105.1.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:23856 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbZI1QQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 12:16:11 -0400
In-Reply-To: <1253902068.10105.1.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Balazs Scheidler wrote:
> One question, how fast is ipv6_dev_get_saddr()? Since the TPROXY target
> can execute on a per-packet path (although the socket match should take
> care of packets that belong to already-established connections), this
> may be performance critical. Is ipv6_dev_get_saddr() something that I
> can call so often?

It probably isn't the best thing to be calling on a per-packet basis, it's
mainly called now on a per-connection basis.  I guess if it's really bad
for you we could do something like ipv6_get_lladdr() does for finding
a link-local address, it might be good enough in this case.

-Brian
