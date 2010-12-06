From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Misuse of LRO, how widespread
Date: Mon, 6 Dec 2010 12:18:29 -0800
Message-ID: <20101206121829.5b8c852e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Olof Johansson <olof@lixom.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40940 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841Ab0LFUSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 15:18:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I inspected all drivers in net-next to see which drivers are using
LRO and which ones are broken. Most concerning is that Chelsio
and Solarflare drivers ignore ETH_FLAG_LRO.

The ones that are using LRO but allow disabling it:
  qlcnic, netxen, mv643, s2io, myi10ge, bnx2x, ixgbe, vmxnet3

One driver seems confused about LRO vs GRO:
  mlx4 - comments about LRO and depends on LRO but driver is using GRO

Drivers with not using ethtool interface to disable LRO:
  pasemi_mac, sfc, ehea, cxgb3, cxgb4

