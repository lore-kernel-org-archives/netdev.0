From: Sebastien Rannou <mxs@sbrk.org>
Subject: Re: [5/6] mvneta: implement SGMII-based in-band link state
 signaling
Date: Wed, 8 Jul 2015 18:30:48 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1507081757260.28659@sbrk.org>
References: <55155D9D.6070800@list.ru>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="2036029021-1673931612-1436373048=:28659"
Cc: netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Stas Sergeev <stsp@list.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55155D9D.6070800@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--2036029021-1673931612-1436373048=:28659
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

Hi Stas,

On Fri, 27 Mar 2015, Stas Sergeev wrote:

> When MDIO bus is unavailable (common setup for SGMII), the in-band
> signaling must be used to correctly track link state.
> This patch enables the in-band status delivery and interrupts for
> links state changes, namely:
> - link up/down
> - link speed
> - duplex full/half
> Upon reciving the appropriate interrupt, the driver updates the
> fixed_phy status to match the received status.

I'm seeing a regression with this patch when trying to netboot an Armada
XP board (by reverting this commit it is fine), the network
link stays down:

[    9.274492] mvneta d0070000.ethernet eth0: Link is Down

(I've added an extra call to phy_print_status() in mvneta_adjust_link() to
get this trace).

I've tried to dig a bit in the code, and it seems that the status.link flag
never gets set in mvneta_fixed_link_update(). If I try to force the
use_inband_status to 0 in mvneta_probe(), it boots properly so I'm not
sure that I need the in-band status/delivery in my case ; I'm using a
custom DTB with a fixed-link:

eth0: ethernet@70000 {
         status = "okay";
         fixed-link = <1 1 1000 0 0>;
         phy-mode = "sgmii";
};

Could there be something missing in the condition that initializes
pp->use_inband_status?

PS: I've also tried to apply this patch without success:
https://lkml.org/lkml/2015/6/18/496

-- 
Sébastien
--2036029021-1673931612-1436373048=:28659--
