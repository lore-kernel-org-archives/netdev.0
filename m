From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: [RFC PATCH] tcp: limit data skbs in qdisc layer
Date: Tue, 10 Jul 2012 21:28:21 +0800
Message-ID: <CAF1ivSZPqzjV_O7kXUskhy9BtKhbhdWixn8OS7sTpYgM8Z4afw@mail.gmail.com>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
	<1341845722.3265.3065.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, ycheng@google.com,
	dave.taht@gmail.com, netdev@vger.kernel.org,
	codel@lists.bufferbloat.net, therbert@google.com,
	mattmathis@google.com, nanditad@google.com, ncardwell@google.com,
	andrewmcgr@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:60281 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752859Ab2GJN3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 09:29:09 -0400
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 1EAF1DBC4A
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 21:28:24 +0800 (CST)
Received: by vcbf11 with SMTP id f11so7990507vcb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 06:28:21 -0700 (PDT)
In-Reply-To: <1341845722.3265.3065.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 9, 2012 at 10:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2012-07-09 at 00:08 -0700, David Miller wrote:
>
>> I'm suspicious and anticipate that 10G will need more queueing than
>> you are able to get away with tg3 at 1G speeds.  But it is an exciting
>> idea nonetheless :-)
>
> There is a fundamental problem calling any xmit function from skb
> destructor.
>
> skb destructor can be called while qdisc lock is taken, so we can
> deadlock trying to reacquire it.
>
> One such path is the dev_deactivate_queue() -> qdisc_reset() ->
> qdisc_reset_queue(), but also any dropped skbs in qdisc.
>
> So I should only do this stuff from a separate context, for example a
> tasklet or timer.
>
> Alternative would be to use dev_kfree_skb_irq() for all dropped skbs in
> qdisc layer.

Hi Eric,

Maybe a bit off topic ...

Could you share how to test qdisc related change?
Assume I'm testing qdisc performance, for example, codel qdisc,
then how to setup the test environment?

Do you use some network simulator, for example, using the special netem qdisc to
simulate slow network/packet loss/network delay, etc?

Thanks,
Lin Ming
