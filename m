From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: performance regression on HiperSockets depending on MTU size
Date: Tue, 27 Nov 2012 06:21:42 +0000 (UTC)
Message-ID: <k91m5l$77a$1@ger.gmane.org>
References: <20121126153242.GA61652@tuxmaker.boeblingen.de.ibm.com>
 <1353946351.30446.1779.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:42612 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755918Ab2K0GV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 01:21:57 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TdEYW-0007OI-7i
	for netdev@vger.kernel.org; Tue, 27 Nov 2012 07:22:04 +0100
Received: from 112.132.205.99 ([112.132.205.99])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 07:22:04 +0100
Received: from xiyou.wangcong by 112.132.205.99 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 07:22:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Nov 2012 at 16:12 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Hi Frank, thanks for this report.
>
> You could tweak tcp_limit_output_bytes, but IMO the root of the problem
> is in the driver itself.
>
> For example, I had to change mlx4 driver for the same problem : Make
> sure a TX packet can be "TX completed" in a short amount of time.
>
> In the case of mlx4, the wait time was 128 us, but I suspect on your
> case its more like an infinite time or several ms.
>  
> The driver is delaying the free of TX skb by a fixed amount of time,
> or relies on following transmits to perform the TX completion
>

Eric,

Do you have a full list of such commits? I am trying to backport TSQ
to 2.6.32, and of course I don't want to miss these commits either.

Thanks!
