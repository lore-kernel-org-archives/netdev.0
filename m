From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 07/16] esp4: Reorganize esp_output
Date: Wed, 26 Apr 2017 14:06:43 +0200
Message-ID: <20170426120643.GV2649@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
 <1492678515-14347-8-git-send-email-steffen.klassert@secunet.com>
 <AM4PR0501MB1940C8509F15D99381D19E2CDB110@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ilan Tayari <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47136 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1954664AbdDZMHA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 08:07:00 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB1940C8509F15D99381D19E2CDB110@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:52:47AM +0000, Ilan Tayari wrote:
> 
> esp_output_head() might do an skb_cow, which then invalidates the esp.esph pointer and causes a crash later on.
> I would expect the ip_esp_hdr() call to be after the esp_output_head() call.
> 
> But it seems like this pointer was saved here around the call to esp_output_head() on purpose.
> Is that really so? 

Yes, it is needed for udpencap, this might also change esp.esph pointer.
I guess this needs to be done also if skb_cow invalidates the esp.esph
pointer.

> 
> Also, esp6/esp6_offload don't make use of esp_info.esph
> Only esp_output_tail() uses it, and could have done everything it does without it.
> So maybe it's un-needed?

IPv6 does not have udpencap, so it might be not needed there.

> 
> I am still testing a fix patch for the crash, there may be also something similar on the RX path, though.

Ok, thanks!
