From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RACE] net: in process_backlog
Date: Fri, 13 Nov 2009 09:17:19 +0800
Message-ID: <412e6f7f0911121717kfc892a5mbe16279d7d41776d@mail.gmail.com>
References: <412e6f7f0911120050w740377c7j2cdf24ef9fd2ca59@mail.gmail.com>
	 <20091112085739.1137f690@nehalam>
	 <412e6f7f0911121554n22a6f975h1fb5df59bd4b84a2@mail.gmail.com>
	 <20091112161123.561d87fe@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:54493 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786AbZKMBRN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 20:17:13 -0500
Received: by pwi3 with SMTP id 3so1699242pwi.21
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 17:17:19 -0800 (PST)
In-Reply-To: <20091112161123.561d87fe@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 8:11 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 13 Nov 2009 07:54:14 +0800
> Changli Gao <xiaosuo@gmail.com> wrote:
>
>>
>> Yea, if the process waits for a RCU grace period, there will be no
>> race. But think about another case:
>> 1. flush_backlog().
> After flush backlog there should be no more skb's with that device
> in the queue, and if more are added, the device is buggy.
>
>> 2. dev_hold(skb->dev); netif_rx(). dev_put(skb->dev);
> There is no dev_hold in netif_rx path.
>

If the caller of netif_rx or netif_rx_ni isn't the device driver self,
it must find and hold the dev, then call netif_rx and put it.

>> 3. wait_for_refs();
>> 4. free(dev);
>> 5. netif_receive_skb(); //skb->dev doesn't present.
>> flush_backlog() can't prevent new skbs are added to backlog. If we
>> swap the flush_backlog() and wait_for_refs(), this case will be OK
>> too.
>
> It is still up to device driver not to add skb's to queue when stoppe=
d.
>

do you mean before calling netif_rx, the caller should check the dev
is alive or not? If so, why not add the check into netif_rx or
netif_rx_ni()? Could you explains why swapping the flush_backlog() and
wait_for_refs() can't work?


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
