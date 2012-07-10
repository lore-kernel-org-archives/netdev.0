From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Tue, 10 Jul 2012 21:37:29 +0800
Message-ID: <CACVXFVM-fhQJX+EFNoFSnuVAjqfRM7OjzbQML7H+tMEjxG7Rug@mail.gmail.com>
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
	<1341908908.3265.4508.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:37216 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387Ab2GJNha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 09:37:30 -0400
Received: by gglu4 with SMTP id u4so11239920ggl.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 06:37:29 -0700 (PDT)
In-Reply-To: <1341908908.3265.4508.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 10, 2012 at 4:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-07-10 at 15:22 +0800, Ming Lei wrote:
>
>> Kernel stack size is 8KB or more, so could you find process creation failure
>> in your ChromeBooks machine at the same time?
>
> I believe you mix a lot of things.
>
> Have you ever heard of sockets limits ?
>
> All available ram on a machine is not for whoever wants it, thanks God.
>
> No : TCP stack was dropping frames, because of socket limits.
>
> Only because skbs were fat (8KB allocated/truesize, for a single 1500
> bytes frame)

Could you explain why the truesize of SKB is 8KB for single
1500bytes frame?

I observed it is 2560bytes for RX SKBs inside asix_rx_fixup with
rx_urb_size of 2048 on beagle-xm.

>
> If application is fast and read skb as soon as the arrive, no problem is
> detected.
>
> But if  application is slow, or a TCP packet is lost on network,
> man packets are queued into ofo queue. And eventually not enough room is
> avalable -> we drop incoming frames, and sender has to restransmit them.
>
> So instead of loading your web pages as fast as possible, you have to
> wait for retransmits.
>
> So you see nothing at all, no kernel logs, no failed memory attempts.
>
> Only its slower than necessary
>
>
>


Thanks,
-- 
Ming Lei
