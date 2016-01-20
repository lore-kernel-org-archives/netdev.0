From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: (unknown)
Date: Wed, 20 Jan 2016 11:23:48 +0100
Message-ID: <1453285431-32498-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Subject: 
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is Damien Riegel's series with minor changes.

regards,
Marc

---

This patchset introduces support for the technologic version of the
SJA1000. Access to IP's registers are proxied through a window,
requiring two bus accesses to read or write a register. These accesses
must be protected by a spinlock to prevent race conditions. Currently,
there is no easy way to allocate and initialize this spinlock.

SJA1000 already provides a way to allocate private data, but
sja1000_platform.c makes no use of it.

Patch 1 adds the capability to allocate and initialize private data on a
per-compatible basis in sja1000_platform.c.

Patch 2 updates device tree documentation to add the technologic
version.

Patch 3 updates the driver to implement the technologic version

Changes in v5:
 - remove empty "static struct sja1000_of_data nxp_data", again
 - add additional check for of_id->data

Changes in v4:
 - add sp_ prefix to technologic functions
 - add empty "static struct sja1000_of_data nxp_data"
 - make "struct sja1000_of_data technologic_data" static
 - get rid of "?" operator in sp_probe()

Changes in v3:
 - moved sp_of_table above sp_probe as it is used in this function
 - removed functions added in v2 and do everyting in sp_probe

Changes in v2:
 - added a patch to allocate and initialize private data
 - changed device tree documentation
 - added a spinlock to protect bus accesses
 - changed sp_{read,write}_reg16 to io{read,write}16


