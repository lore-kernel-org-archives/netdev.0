From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Tue, 10 Jul 2012 10:28:28 +0200
Message-ID: <1341908908.3265.4508.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	 <1341481760.2583.3579.camel@edumazet-glaptop>
	 <CACVXFVNYwNrdWS_EiQ4O0-ou369AQ2tB4qbvmzY1rt5T3QnyUw@mail.gmail.com>
	 <1341842043.3265.2914.camel@edumazet-glaptop>
	 <CACVXFVNdiwVn1Mo--N4N0HdYrEJizExtd_cppT4tS=mjog2PKw@mail.gmail.com>
	 <1341895143.3265.4049.camel@edumazet-glaptop>
	 <CACVXFVPgqtSN3BrEXRxSv4yxaxCni495SxZNXBmYQpagmxk2tQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:35314 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939Ab2GJI2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 04:28:33 -0400
Received: by eeit10 with SMTP id t10so4575478eei.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 01:28:32 -0700 (PDT)
In-Reply-To: <CACVXFVPgqtSN3BrEXRxSv4yxaxCni495SxZNXBmYQpagmxk2tQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 15:22 +0800, Ming Lei wrote:

> Kernel stack size is 8KB or more, so could you find process creation failure
> in your ChromeBooks machine at the same time?

I believe you mix a lot of things.

Have you ever heard of sockets limits ?

All available ram on a machine is not for whoever wants it, thanks God.

No : TCP stack was dropping frames, because of socket limits.

Only because skbs were fat (8KB allocated/truesize, for a single 1500
bytes frame)

If application is fast and read skb as soon as the arrive, no problem is
detected.

But if  application is slow, or a TCP packet is lost on network,
man packets are queued into ofo queue. And eventually not enough room is
avalable -> we drop incoming frames, and sender has to restransmit them.

So instead of loading your web pages as fast as possible, you have to
wait for retransmits.

So you see nothing at all, no kernel logs, no failed memory attempts.

Only its slower than necessary
