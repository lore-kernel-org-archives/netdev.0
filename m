From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Fri, 08 Nov 2013 07:11:18 -0800
Message-ID: <1383923478.9412.240.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108130244.GE5876@order.stressinduktion.org>
	 <1383919418.9412.234.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108142856.GA28330@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:59938 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757773Ab3KHPLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 10:11:23 -0500
Received: by mail-pb0-f49.google.com with SMTP id um1so277985pbc.36
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 07:11:19 -0800 (PST)
In-Reply-To: <20131108142856.GA28330@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 15:28 +0100, Hannes Frederic Sowa wrote:

> What do you think about using a timer to keep the reseed out of fast-path
> and switch to the non-arch get_random_bytes instead?

Well, the initial seed value is get_random_bytes(). I felt that using a
xor with the _arch() version would be safe enough.

For the timer, I do not think its worth the pain : Do you want a per cpu
timer, or a global one ?

The unlikely() clause makes the test very small and test is well
predicted.
