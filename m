From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fec: fix potential use after free
Date: Thu, 19 Dec 2013 12:18:38 -0800
Message-ID: <1387484318.19078.377.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131219193231.GB14612@netboy>
	 <CAHrpEqQre+Y=+m-RX9nADA2Z7NirxYH0yKCwMSZpnn2GKx0jkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:54943 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655Ab3LSUSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:18:40 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so1627739pbb.4
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 12:18:39 -0800 (PST)
In-Reply-To: <CAHrpEqQre+Y=+m-RX9nADA2Z7NirxYH0yKCwMSZpnn2GKx0jkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 14:05 -0600, Frank Li wrote:

> I think It is not related with hw_lock.  After trigger transfer,
> there are possibility that tx completed immediately and irq handle
> will free skb.

Well, before the de5fb0a05348 commit, tx completion and start_xmit()
could not run in //

So hw_lock was effectively preventing the issue.
