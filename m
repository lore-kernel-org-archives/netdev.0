From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery
 stalls on v3.
Date: Fri, 12 Dec 2014 09:27:05 -0800
Message-ID: <1418405225.13491.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
	 <6700748.kZ07xrNvHX@h2o.as.studentenwerk.mhn.de>
	 <1418238603.27198.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <2630078.LdJXSsPB40@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:59394 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030876AbaLLR1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 12:27:08 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so7402840ier.13
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 09:27:07 -0800 (PST)
In-Reply-To: <2630078.LdJXSsPB40@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-12 at 17:58 +0100, Wolfgang Walter wrote:

> This fixes hangs of local tcp connections over ipsec tunnels where
> pmtu is lower than the mtu of the interface.

Again this is a work around, the one liner patch is not a clean patch.

Something is wrong, we should fix GSO path instead.

Why ? Because we can queue a GSO packet in a qdisc, then later call
sk_setup_caps() (too late)
