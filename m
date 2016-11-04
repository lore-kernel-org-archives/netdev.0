From: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v6 0/7] add NS2 support to bgmac
Date: Fri,  4 Nov 2016 01:10:55 -0400
Message-ID: <1478236262-3351-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Changes in v6:
* Use a common bgmac_phy_connect_direct (per Rafal Milecki) 
* Rebased on latest net-next
* Added Reviewed-by to the relevant patches


Changes in v5:
* Change a pr_err to netdev_err (per Scott Branden)
* Reword the lane swap binding documentation (per Andrew Lunn)


Changes in v4:
* Actually send out the lane swap binding doc patch (Per Scott Branden)
* Remove unused #define (Per Andrew Lunn)


Changes in v3:
* Clean-up the bgmac DT binding doc (per Rob Herring)
* Document the lane swap binding and make it generic (Per Andrew Lunn)


Changes in v2:
* Remove the PHY power-on (per Andrew Lunn)
* Misc PHY clean-ups regarding comments and #defines (per Andrew Lunn)
  This results on none of the original PHY code from Vikas being
  present.  So, I'm removing him as an author and giving him
  "Inspired-by" credit.
* Move PHY lane swapping to PHY driver (per Andrew Lunn and Florian
  Fainelli)
* Remove bgmac sleep (per Florian Fainelli)
* Re-add bgmac chip reset (per Florian Fainelli and Ray Jui)
* Rebased on latest net-next
* Added patch for bcm54xx_auxctl_read, which is used in the BCM54810


Jon Mason (7):
  net: phy: broadcom: add bcm54xx_auxctl_read
  Documentation: devicetree: add PHY lane swap binding
  net: phy: broadcom: Add BCM54810 PHY entry
  Documentation: devicetree: net: add NS2 bindings to amac
  net: ethernet: bgmac: device tree phy enablement
  net: ethernet: bgmac: add NS2 support
  arm64: dts: NS2: add AMAC ethernet support

 .../devicetree/bindings/net/brcm,amac.txt          | 16 +++--
 Documentation/devicetree/bindings/net/phy.txt      |  4 ++
 arch/arm64/boot/dts/broadcom/ns2-svk.dts           |  5 ++
 arch/arm64/boot/dts/broadcom/ns2.dtsi              | 12 ++++
 drivers/net/ethernet/broadcom/bgmac-bcma.c         | 22 +++++++
 drivers/net/ethernet/broadcom/bgmac-platform.c     | 74 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bgmac.c              | 32 +++-------
 drivers/net/ethernet/broadcom/bgmac.h              |  9 +++
 drivers/net/phy/Kconfig                            |  2 +-
 drivers/net/phy/broadcom.c                         | 68 +++++++++++++++++++-
 include/linux/brcmphy.h                            | 10 +++
 11 files changed, 222 insertions(+), 32 deletions(-)

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
