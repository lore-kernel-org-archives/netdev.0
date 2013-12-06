From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: auto corking
Date: Fri, 06 Dec 2013 10:36:43 -0800
Message-ID: <1386355003.30495.273.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7467@saturn3.aculab.com>
	 <52A1F603.2030208@hp.com>
	 <1386351976.30495.266.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52A2114E.1070208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:33588 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab3LFSgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 13:36:46 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so1540864pbb.32
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 10:36:46 -0800 (PST)
In-Reply-To: <52A2114E.1070208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-06 at 10:02 -0800, Rick Jones wrote:

> You mean write, write, read?

Yes, this kind of things. 

"write, write, write, write, < pause or read >, .."


TCP stack tends to increase cwin by insane values in this case.
(one increase per 'line' / ACK)

Just ssh onto a host and look at "ss -emoi src :22" after issuing some
line oriented commands like "ps aux"

I can easily get cwin = 700, while I never sent more than 30KB at once.

If then I send 2MB, they can be sent all at once (and probably trigger
tons of drops)
