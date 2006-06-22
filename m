From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 00/21] e1000: driver update to 7.1.9-k2
Date: Wed, 21 Jun 2006 22:18:15 -0700
Message-ID: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:39688 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751565AbWFVFOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:07 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

A large number of e1000 patches this update, including the release of
the integrated NIC in the ICH8 motherboard chipset, which has been
officially released into the public. Also known as i965, the lan
chipset on this motherboard is fully supported by this driver.

The motherboard actually comes with two different PHY's, one that
supports gigabit speeds and one that only does 10/100. This driver
supports both of them.

All of these changes correspond with the 7.1.9 release on SF this
week, and have been tested and validated by our team, who did and
an excellent job ;^).

Furthermore, the patches included also fixes included in the 7.0.38
and 7.0.41 releases, which were not yet merged into the kernel. This
patch series brings the kernel driver up to current.


---

Summary of patches:

[01]: fix loopback ethtool test
[02]: rework driver hardware reset locking
[03]: Make PHY powerup/down a function
[04]: fix CONFIG_PM blocks
[05]: small performance tweak by removing double code
[06]: add smart power down code
[07]: change printk into DPRINTK
[08]: recycle skb
[09]: rework module param code with uninitialized values
[10]: force register write flushes to circumvent broken platforms
[11]: disable CRC stripping workaround
[12]: fix adapter led blinking inconsistency
[13]: add E1000_BIG_ENDIAN symbol
[14]: M88 PHY workaround
[15]: check return value of _get_speed_and_duplex
[16]: disable ERT
[17]: add ich8lan core functions
[18]: integrate ich8 support into driver
[19]: allow user to disable ich8 lock loss workaround
[20]: add ich8lan device ID's
[21]: increase version to 7.1.9-k2


---

Since these patches are rather large together, they are also available
over http here:
    http://foo-projects.org/~sofar/e1000-7.1.9-k2/
And in a tarball:
    http://foo-projects.org/~sofar/e1000-7.1.9-k2/e1000-patches-7.1.9-k2.tar.bz2
---

Jeff, please pull from our git repository:

git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream


These patches are against
    netdev-2.6#upstream 612eff0e3715a6faff5ba1b74873b99e036c59fe
(Brian Haley <brian.haley@hp.com> / [PATCH] s2io: netpoll support)

Cheers,

Auke


---
 drivers/net/e1000/e1000.h         |   10 
 drivers/net/e1000/e1000_ethtool.c |  143 +--
 drivers/net/e1000/e1000_hw.c      | 1770 +++++++++++++++++++++++++++++++++++---
 drivers/net/e1000/e1000_hw.h      |  400 ++++++++
 drivers/net/e1000/e1000_main.c    |  386 +++++---
 drivers/net/e1000/e1000_osdep.h   |   16 
 drivers/net/e1000/e1000_param.c   |  213 ++--
 7 files changed, 2539 insertions(+), 399 deletions(-)


--
Auke Kok <auke-jan.h.kok@intel.com>
