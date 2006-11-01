From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 00/18] e1000: features, updates, documentation
Date: Wed, 01 Nov 2006 09:50:43 -0800
Message-ID: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:11792 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946882AbWKARmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:42:50 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Here are patches for e1000 for #upstream in netdev-2.6.git. Most of the
patches are maintenance and minor fixes only, but a few are significant
and more complex:

o Patch to enable IPv6 TSO for all e1000 hardware
o Add support for 3 newly packaged existing silicon devices
o Add a MSI interrupt servicing routine for pci-e hardware
o Add dynamic interrupt moderation algorithm favouring low latency but
  not affecting bulk throughput traffic situations. This improves small
  packet performance significantly.

(Summary below.)


These changes are available through git.

Jeff, please pull:

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

these patches are against
 netdev-2.6#upstream a01ad6b4b316afb7f9c48bde3590c0d6c063b1b4


Cheers,

Auke

---

Jesse Brandeburg <jesse.brandeburg@intel.com>:
     e1000: add mmiowb() for IA64 to sync tail writes
     e1000: Remove unneeded and unwanted memsets
     e1000: add queue restart counter
     e1000: Only set IDE for tx when we are using TIDV/TADV
     e1000: add dynamic generic MSI interrupt routine
     e1000: add dynamic itr modes

Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
     e1000: fix VR powerdown code
     e1000: reorder pci-e infor struct
     e1000: rename ICH8 flash macros

Auke Kok <auke-jan.h.kok@intel.com>:
     e1000: whitespace changes, comments, typos
     e1000: Remove DISABLE_MULR debug code
     e1000: FIX: enable hw TSO for IPV6
     e1000: Enble early receive (ERT) on 82573
     e1000: simplify skb_put call.
     e1000: New hardware support
     e1000: reorder e1000_param.c
     e1000: increment version to 7.3.15-k2
     e1000: update README for e1000

---

 Documentation/networking/e1000.txt |  451 ++++++++++++++++++++-------------
 drivers/net/e1000/e1000.h          |   17 +
 drivers/net/e1000/e1000_ethtool.c  |   36 +-
 drivers/net/e1000/e1000_hw.c       |  137 +++++-----
 drivers/net/e1000/e1000_hw.h       |   90 +++---
 drivers/net/e1000/e1000_main.c     |  491 +++++++++++++++++++++++++++++--------
 drivers/net/e1000/e1000_osdep.h    |    9 
 drivers/net/e1000/e1000_param.c    |  106 +++----
 8 files changed, 852 insertions(+), 485 deletions(-)


---
Auke Kok <auke-jan.h.kok@intel.com>
