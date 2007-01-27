From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH -MM]: updated e1000  - new hardware initialization code (replacement
 patch)
Date: Sat, 27 Jan 2007 12:06:07 -0800
Message-ID: <45BBB0AF.4040709@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	cramerj <cramerj@intel.com>
To: Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752379AbXA0UGM@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andrew,

Please pull:

git-pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-mm

to receive an updated version of the new e1000 hardware initialization code. 
This version incorporates both previously sent patches and replaces them, as 
well as adding some minor extra kdoc headers.

The patch applies cleanly against jgarzik's netdev-2.6 #upstream commit 
5ad0d383ddbf0d2fce43b8aac267a6c299fd2dff.

the patch is also available in monolithic form over http:
http://foo-projects.org/~sofar/e1000_git_new_device_init_code.patch.bz2 (166kb)
or http://foo-projects.org/~sofar/e1000_git_new_device_init_code.patch (1.2mb)

Cheers,

Auke



---


e1000: New device initialization code, fixes

From: Jeb Cramer <cramerj@intel.com>

This rewrite of the hardware initialization code splits up the driver
low-level initialization code per chipset family. Several families exist
with different initialization code per chipset, revision, and this allows
us later to select only enable certain devices in the driver. The current
code enables all previous drivers and thus doesn't change anything to the
user, but is radically different internally.

Mac and phy layers are also split, and everything is grouped in an API
layer that the driver uses to interface the hardware.

Support was added for a PCI-e 4-port Fibre version of the PRO/1000 PT quad
port adapter (device 0x10a5). MTU changes on a downed interface require
a phy commit to enact the new size immediately.

Replace hard coded RAR numbers with constant. Add several function
description and fix some small copy+paste errors in others. Fix link
speed detection on PCI adapters showing wrong PCI bus speed. Fix laa
detection. Rewrite tbi static for 82543. Fix mta list overflow. Don't
unmap skb's twice in occasions, but set dma=0. Flatten dhcp generic
function for readability. Change force phy speed duplex setup to be
void and static.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeb Cramer <cramerj@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

  drivers/net/e1000/Makefile            |   19
  drivers/net/e1000/e1000.h             |   97
  drivers/net/e1000/e1000_80003es2lan.c | 1377 +++++
  drivers/net/e1000/e1000_80003es2lan.h |   89
  drivers/net/e1000/e1000_82540.c       |  670 ++
  drivers/net/e1000/e1000_82541.c       | 1305 +++++
  drivers/net/e1000/e1000_82541.h       |   86
  drivers/net/e1000/e1000_82542.c       |  551 ++
  drivers/net/e1000/e1000_82543.c       | 1643 ++++++
  drivers/net/e1000/e1000_82543.h       |   45
  drivers/net/e1000/e1000_82571.c       | 1127 ++++
  drivers/net/e1000/e1000_82571.h       |   42
  drivers/net/e1000/e1000_api.c         | 1174 ++++
  drivers/net/e1000/e1000_api.h         |  161 +
  drivers/net/e1000/e1000_defines.h     | 1297 +++++
  drivers/net/e1000/e1000_ethtool.c     |  470 +-
  drivers/net/e1000/e1000_hw.c          | 9038 ---------------------------------
  drivers/net/e1000/e1000_hw.h          | 3859 ++------------
  drivers/net/e1000/e1000_ich8lan.c     | 2427 +++++++++
  drivers/net/e1000/e1000_ich8lan.h     |  110
  drivers/net/e1000/e1000_mac.c         | 1939 +++++++
  drivers/net/e1000/e1000_mac.h         |   84
  drivers/net/e1000/e1000_main.c        |  936 ++-
  drivers/net/e1000/e1000_manage.c      |  388 +
  drivers/net/e1000/e1000_manage.h      |   83
  drivers/net/e1000/e1000_nvm.c         |  859 +++
  drivers/net/e1000/e1000_nvm.h         |   61
  drivers/net/e1000/e1000_osdep.h       |   57
  drivers/net/e1000/e1000_param.c       |  100
  drivers/net/e1000/e1000_phy.c         | 1932 +++++++
  drivers/net/e1000/e1000_phy.h         |  159 +
  drivers/net/e1000/e1000_regs.h        |  236 +
  32 files changed, 19321 insertions(+), 13100 deletions(-)
