From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2 0/2] ravb: Add missing free_irq() calls to ravb_close()
Date: Sat,  7 May 2016 13:17:10 +0200
Message-ID: <1462619832-5177-1-git-send-email-geert+renesas@glider.be>
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Simon Horman <horms+renesas@verge.net.au>,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi Dave,

When reopening the network device on ra7795/salvator-x, e.g. after a
DHCP timeout:

    IP-Config: Reopening network devices...
    genirq: Flags mismatch irq 139. 00000000 (eth0:ch24:emac) vs. 00000000 (
    ravb e6800000.ethernet eth0: cannot request IRQ eth0:ch24:emac
    IP-Config: Failed to open eth0
    IP-Config: No network devices available

The "mismatch" is due to requesting an IRQ that is already in use,
while IRQF_PROBE_SHARED wasn't set.

However, the real cause is that ravb_close() doesn't release any of the
R-Car Gen3-specific secondary IRQs. Hence the following two patches add
the missing free_irq() calls to fix this.

As the code has been changed in net-next.git to support more interrupts,
and these weren't freed neither, I'm sending two patches:
  1. The first patch applies to net.git,
  2. The second patch applies to net-next.git.

If you prefer the second patch to be replaced by a version that applies
to net-next.git after you will have applied the first patch to net.git,
and merged net.git into net-next.git, just let me know.

Chances compared to the previous version:
  - Add version against net.git,
  - Clearly state which version the second patch is against,
  - Add Fixes tags.

Thanks!

Geert Uytterhoeven (1):
  ravb: Add missing free_irq() call to ravb_close()
  ravb: Add missing free_irq() calls to ravb_close()

 drivers/net/ethernet/renesas/ravb_main.c       | 9 +++++++
 1 files changed, 9 insertions(+)

-- 
1.9.1

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
