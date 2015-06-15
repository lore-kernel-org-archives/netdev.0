From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/4] switchdev: avoid duplicate packet
 forwarding
Date: Mon, 15 Jun 2015 16:25:51 -0700 (PDT)
Message-ID: <20150615.162551.805611215439524288.davem@davemloft.net>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com, roopa@cumulusnetworks.com,
	ronen.arad@intel.com, john.r.fastabend@intel.com, andrew@lunn.ch,
	f.fainelli@gmail.com, linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbbFOXZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 19:25:53 -0400
In-Reply-To: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Sat, 13 Jun 2015 11:04:26 -0700

> The switchdev port driver must do two things:
> 
> 1) Generate a fwd_mark for each switch port, using some unique key of the
>    switch device (and optionally port).  This is a one-time operation done
>    when port's netdev is setup.
> 
> 2) On packet ingress from port, mark the skb with the ingress port's
>    fwd_mark.  If the device supports it, it's useful to only mark skbs
>    which were already forwarded by the device.  If the device does not
>    support such indication, all skbs can be marked, even if they're
>    local dst.
> 
> Two new 32-bit fields are added to struct sk_buff and struct netdevice to
> hold the fwd_mark.  I've wrapped these with CONFIG_NET_SWITCHDEV for now. I
> tried using skb->mark for this purpose, but ebtables can overwrite the
> skb->mark before the bridge gets it, so that will not work.
> 
> In general, this fwd_mark can be used for any case where a packet is
> forwarded by the device and a copy is sent to the CPU, to avoid the kernel
> re-forwarding the packet.  sFlow is another use-case that comes to mind,
> but I haven't explored the details.

Generally I'm against adding new fields fo sk_buff but I'm trying to be
open minded. :-)

About the per-device fwd_mark, if the key attribute is uniqueness,
let's just do it right and use something like lib/idr.c to generate
truly unique indices at probe time for all devices using this
facility.  I like that better than having them be unique by a happy
accident.
