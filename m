From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Wed, 10 Aug 2016 10:49:24 -0700
Message-ID: <0da01875-b55a-c0fd-bd5f-05bb41fbd7fc@gmail.com>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
 <57AA2001.2010904@codeaurora.org>
 <214dcbb7-0c3b-1e00-3e50-db513d77b10b@gmail.com>
 <57AA7ED0.9000707@codeaurora.org>
 <85b76eca-5473-6724-0c9d-7b6fa7677f50@gmail.com>
 <57AB589D.3010509@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35939 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbcHJSOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:14:19 -0400
In-Reply-To: <57AB589D.3010509@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2016 09:38 AM, Timur Tabi wrote:
> Florian Fainelli wrote:
>>> >Is there an easy way for me to stop the RX path before I set
>>> rxbuf_size?
>>> >  Some netif_xxx function I can call?
>> napi_disable() should take care of that.
> 
> It appears that if I call netif_stop_queue() *afer* calling
> napi_disable(), I get a hang and/or TX timeout.  Since emac_mac_down()
> does this:
> 
>     netif_stop_queue(netdev);
>     napi_disable(&adpt->rx_q.napi);
> 
> I cannot call just napi_disable() in emac_change_mtu(), because when I
> then call emac_mac_down(), the first thing it does is call
> netif_stop_queue(), and that's when I timeout/hang.

Whatever emac_mac_down() does you can unroll it in the change_mtu
callback anyway, so if this a problematic sequence you can work around it.

> 
> Unfortunately, I cannot even do this:
> 
>     netif_stop_queue(netdev);
>     napi_disable(&adpt->rx_q.napi);
>     netif_stop_queue(netdev);
>     napi_disable(&adpt->rx_q.napi);
> 
> Even though I've already called netif_stop_queue(), calling it again
> causes the timeout/hang.

Buf if this is really what you copy/pasted here, why do this twice anyway?

> 
> Is this expected?  I never understood why I needed to call
> netif_stop_queue() before napi_disable().  I do see some drivers do not
> call netif_stop_queue().  I even saw a driver that calls them in reverse
> order, so I don't understand why that sequence breaks for me but not him.
> 

Not clear how the two relate with each other here, must be specific to
your driver implementation somehow.
-- 
Florian
