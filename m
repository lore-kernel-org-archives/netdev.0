From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: question about netif_rx
Date: Sun, 11 Aug 2013 17:56:40 +0200
Message-ID: <20130811155640.GA10070@electric-eye.fr.zoreil.com>
References: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <julia.lawall@lip6.fr> :
> To my limited understanding, in a NAPI polling function, one should use 
> netif_receive_skb, rather than netif_rx.

Nit: or napi_gro_receive (+ napi_gro_flush with __napi_complete) when the
device offers some checksum offloading features.

> However, the via-velocity driver defines the NAPI polling function
> velocity_poll, which is the only caller of velocity_rx_srv, which
> is the only caller of velocity_receive_frame, which calls netif_rx.
> The call to netif_rx seems to predate the introduction of NAPI in
> this driver.  Is this correct?

You are right. It's a leftover of the NAPI changes in this driver.

Can you send a netif_receive_skb replacement patch for it ?

-- 
Ueimor
