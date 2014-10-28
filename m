From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] bridge: Add support for IEEE 802.11 Proxy ARP
Date: Mon, 27 Oct 2014 18:20:32 -0700
Message-ID: <20141027182032.1c5dcffa@urahara>
References: <1414100957-8288-1-git-send-email-kyeyoonp@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jouni@qca.qualcomm.com, netdev@vger.kernel.org
To: Kyeyoon Park <kyeyoonp@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36483 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024AbaJ1BUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 21:20:44 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so6599324pab.34
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 18:20:44 -0700 (PDT)
In-Reply-To: <1414100957-8288-1-git-send-email-kyeyoonp@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Oct 2014 14:49:17 -0700
Kyeyoon Park <kyeyoonp@qca.qualcomm.com> wrote:

> From: Kyeyoon Park <kyeyoonp@codeaurora.org>
> 
> This feature is defined in IEEE Std 802.11-2012, 10.23.13. It allows
> the AP devices to keep track of the hardware-address-to-IP-address
> mapping of the mobile devices within the WLAN network.
> 
> The AP will learn this mapping via observing DHCP, ARP, and NS/NA
> frames. When a request for such information is made (i.e. ARP request,
> Neighbor Solicitation), the AP will respond on behalf of the
> associated mobile device. In the process of doing so, the AP will drop
> the multicast request frame that was intended to go out to the wireless
> medium.
> 
> It was recommended at the LKS workshop to do this implementation in
> the bridge layer. vxlan.c is already doing something very similar.
> The DHCP snooping code will be added to the userspace application
> (hostapd) per the recommendation.
> 
> This RFC commit is only for IPv4. A similar approach in the bridge
> layer will be taken for IPv6 as well.
> 
> Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>

Looks good. Maybe at some point VXLAN and bridge should share
more code or at least the same options.

I a little worried that this could be DoS'd.
