From: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 0/3] 1588 support for Zynq Ultrascale+ MPSoC
Date: Fri, 11 Sep 2015 13:27:35 +0530
Message-ID: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	<punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	<alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	<harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series adds 1588 support in Cadence MACB driver for Zynq Ultrascale+ MPSoC

This IP supports HW timestamping and this is accesible through extended BD.
The first patch adds support for extended BD through a config option.
Since this required the use two extra u32 variables in the macb_dma_desc
structure, we opted for a static config option.
The second patch adds support to access the timestamp in TX and RX paths,
register to PTP framework and provide time and frequency adjustment.
This was tested in  two step mode using linuxptp.
The TSU clock is expected to be provided through devicetree.

Harini Katakam (3):
  net: macb: Add support for extended BD with a config option
  net: macb: Add support for 1588 for Zynq Ultrascale+ MPSoC
  devicetree: macb: Add optional property tsu-clk

 Documentation/devicetree/bindings/net/macb.txt |    3 +
 drivers/net/ethernet/cadence/Kconfig           |    8 +
 drivers/net/ethernet/cadence/macb.c            |  376 +++++++++++++++++++++++-
 drivers/net/ethernet/cadence/macb.h            |   72 +++++
 4 files changed, 451 insertions(+), 8 deletions(-)

-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
