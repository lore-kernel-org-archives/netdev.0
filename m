From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 09/11] sfc: Prefetch RX skb header area
Date: Wed, 19 Jun 2013 15:56:21 -0700
Message-ID: <1371682581.3252.353.camel@edumazet-glaptop>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
	 <1371680432.1956.116.camel@bwh-desktop.uk.level5networks.com>
	 <1371681389.3252.339.camel@edumazet-glaptop>
	 <1371681557.1956.121.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:38164 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935028Ab3FSW40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:56:26 -0400
Received: by mail-ee0-f51.google.com with SMTP id e52so3527770eek.24
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 15:56:25 -0700 (PDT)
In-Reply-To: <1371681557.1956.121.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 23:39 +0100, Ben Hutchings wrote:

> You can't use build_skb() if you put multiple RX buffers in a page.  See
> <1365805319.2791.18.camel@bwh-desktop.uk.solarflarecom.com>.

Well, you use small skb (used to have 64 bytes headroom and you changed
it to 128) and attach a frag on it, so anyway build_skb() brings
nothing.

I suspect you have a win on workloads with flood of rx, but on moderate
load sk_buff will be cold, so the cache adds latencies.

My feeling is that this kind of tradeoff should not be per driver.
