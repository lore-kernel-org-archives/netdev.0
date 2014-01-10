From: Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 0/2] stmmac: Fix kernel crashes for jumbo frames
Date: Fri, 10 Jan 2014 17:47:46 -0600
Message-ID: <1389397669-10929-1-git-send-email-vbridgers2013@gmail.com>
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org,
	rayagond-AmucfkJibqKGw+nKnLezzg@public.gmane.org, vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These patches address two kernel crashes seen when using jumbo frames on 
the Synopsys stmmac driver, and adds device tree configurability for the 
maximum mtu. The Synopsys emac fifo sizes can be configured when a logic
design is synthesized, but does not provide a way for a driver to query the
exact fifo size. 

The crashes seen were due to two issues. 

1) The dma buffer size was being set after the dma buffers were allocated.
This caused a crash when changing the mtu since it was possible the buffers
would subsequently be freed using an incorrect dma buffer size. This could
also cause kernel panics due to memory corruption since a large mtu size could
have been configured, but the dma buffers were not sized accordingly. 

2) Jumbo frames were being enabled by default, but the dma buffers were not
sized accordingly. This caused memory corruption in the context of certain
types of network traffic, leading to kernel panics. 

I've tested these changes using automated, reproducible testware. I can
demonstrate the panics described before the fixes and show that the fixes
address the problems described. 

Testing and improvements continue through the use of the mentioned automated
and reproducible testware. 

Vince Bridgers

Vince Bridgers (2):
  dts: Add a binding for Synopsys emac max-mtu
  stmmac: Fix kernel crashes for jumbo frames

 Documentation/devicetree/bindings/net/stmmac.txt   |    5 +++++
 drivers/net/ethernet/stmicro/stmmac/common.h       |    4 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    7 ++-----
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    7 ++++++-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 +++++++----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    5 +++++
 include/linux/stmmac.h                             |    1 +
 8 files changed, 30 insertions(+), 12 deletions(-)

-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
