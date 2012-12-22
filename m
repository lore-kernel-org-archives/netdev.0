From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 16:01:21 -0800
Message-ID: <1356134481.21834.8090.camel@edumazet-glaptop>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	 <1356114663.21834.7697.camel@edumazet-glaptop>
	 <CALvgte9x4LWV8rsquKzNoVcXM14xZjvyuTgpHr-ynZXfGtzzpw@mail.gmail.com>
	 <1356118052.21834.7793.camel@edumazet-glaptop>
	 <CALvgte9WJRR95B5WCTavF0w3Kvf+MksZtyY4OQ=ioAe71BasCw@mail.gmail.com>
	 <1356129948.21834.8002.camel@edumazet-glaptop>
	 <CALvgte-tpvyBF608MahqLc_JFZNzg2q1FpsUY72fDDicbdsBWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhiyun Qian <zhiyunq@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:52117 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab2LVABX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 19:01:23 -0500
Received: by mail-pb0-f41.google.com with SMTP id xa7so3004913pbc.14
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 16:01:23 -0800 (PST)
In-Reply-To: <CALvgte-tpvyBF608MahqLc_JFZNzg2q1FpsUY72fDDicbdsBWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 18:52 -0500, Zhiyun Qian wrote:

> It seems that it is not straightforward to simply move tcp_ack()
> before tcp_validate_incoming() as tcp_ack() currently assumes the tcp
> sequence number is already validated and it may adjust certain states
> purely depending on the ACK number. I guess the solution is to extract
> all safety checks out and put at the very beginning. The rest of the
> code in tcp_validate_incoming() and tcp_ack() may still need to
> perform the redundant checks since if some state changes are dependent
> on the sequence number or ACK number (e.g., window update).
> 
> I'm willing to help on this. Perhaps I can draft an initial patch and
> you can help take a look before I submit it?

I began coding a serie of patches.

Part of the problem comes from a 'fast path' idea that was nice 20 years
ago but no longer a real killer these days.

So some tests are duplicated, others are not correctly done.

For example, the fast path misses the more complete tests done in
tcp_ack()

Its a big mess.
