From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v7 0/8] thunderbolt: Introducing Thunderbolt(TM) Networking
Date: Tue, 27 Sep 2016 16:43:33 +0300
Message-ID: <1474983821-2313-1-git-send-email-amir.jer.levy@intel.com>
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: gregkh@linuxfoundation.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver enables Thunderbolt Networking on non-Apple platforms
running Linux.

Thunderbolt Networking provides peer-to-peer connections to transfer
files between computers, perform PC migrations, and/or set up small
workgroups with shared storage.

This is a virtual connection that emulates an Ethernet adapter that
enables Ethernet networking with the benefit of Thunderbolt superfast
medium capability.

Thunderbolt Networking enables two hosts and several devices that
have a Thunderbolt controller to be connected together in a linear
(Daisy chain) series from a single port.

Thunderbolt Networking for Linux is compatible with Thunderbolt
Networking on systems running macOS or Windows and also supports
Thunderbolt generation 2 and 3 controllers.

Note that all pre-existing Thunderbolt generation 3 features, such as
USB, Display and other Thunderbolt device connectivity will continue
to function exactly as they did prior to enabling Thunderbolt Networking.

Code and Software Specifications:
This kernel code creates a virtual ethernet device for computer to
computer communication over a Thunderbolt cable.
The new driver is a separate driver to the existing Thunderbolt driver.
It is designed to work on systems running Linux that
interface with Intel Connection Manager (ICM) firmware based
Thunderbolt controllers that support Thunderbolt Networking.
The kernel code operates in coordination with the Thunderbolt user-
space daemon to implement full Thunderbolt networking functionality.

Hardware Specifications:
Thunderbolt Hardware specs have not yet been published but are used
where necessary for register definitions. 

Changes since v6:
 - Removed (TM) from Kconfig
 - Removed redundant DRV_NAME macro
 - Removed copyright notice from Makefile
 - Moved networking.txt file to Documentation/Thunderbolt/
 - Edited patch descriptions
 - Edited documentation in networking.txt

These patches were pushed to GitHub where they can be reviewed more
comfortably with green/red highlighting:
	https://github.com/01org/thunderbolt-software-kernel-tree

Daemon code:
	https://github.com/01org/thunderbolt-software-daemon

For reference, here's a link to version 6:
[v6]:	https://lkml.org/lkml/2016/8/1/233

Amir Levy (8):
  thunderbolt: Macro rename
  thunderbolt: Updating the register definitions
  thunderbolt: Kconfig for Thunderbolt Networking
  thunderbolt: Communication with the ICM (firmware)
  thunderbolt: Networking state machine
  thunderbolt: Networking transmit and receive
  thunderbolt: Networking doc
  thunderbolt: Adding maintainer entry

 Documentation/00-INDEX                   |    2 +
 Documentation/thunderbolt/networking.txt |  132 ++
 MAINTAINERS                              |    8 +-
 drivers/thunderbolt/Kconfig              |   27 +-
 drivers/thunderbolt/Makefile             |    3 +-
 drivers/thunderbolt/icm/Makefile         |    2 +
 drivers/thunderbolt/icm/icm_nhi.c        | 1622 +++++++++++++++++++++
 drivers/thunderbolt/icm/icm_nhi.h        |   92 ++
 drivers/thunderbolt/icm/net.c            | 2264 ++++++++++++++++++++++++++++++
 drivers/thunderbolt/icm/net.h            |  297 ++++
 drivers/thunderbolt/nhi_regs.h           |  115 +-
 11 files changed, 4555 insertions(+), 9 deletions(-)
 create mode 100644 Documentation/thunderbolt/networking.txt
 create mode 100644 drivers/thunderbolt/icm/Makefile
 create mode 100644 drivers/thunderbolt/icm/icm_nhi.c
 create mode 100644 drivers/thunderbolt/icm/icm_nhi.h
 create mode 100644 drivers/thunderbolt/icm/net.c
 create mode 100644 drivers/thunderbolt/icm/net.h

-- 
2.7.4

