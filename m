From: Quentin Lambert <lambert.quentin@gmail.com>
Subject: [PATCH] moving from pci to dma
Date: Mon, 12 Jan 2015 11:02:39 +0100
Message-ID: <20150112100239.GA9009@sloth>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces the references to the deprecated pci api with the
corresponding dma api.

To ensure that it was possible to access the dev field of pci_dev without
checking for nullity we looked for similar access in the execution
flow.

The most straight forward are "&id->dev" and "pci_get_drvdata(id)" where
id is the variable whose type is pci_dev.

We also found "pci_enable_device(id)" to be satisfying since the call
accesses other field without checking for nullity.

Quentin Lambert (1):
  atm: remove deprecated use of pci api

 drivers/atm/eni.c       | 8 +++++---
 drivers/atm/he.c        | 2 +-
 drivers/atm/lanai.c     | 9 +++++----
 drivers/atm/nicstar.c   | 4 ++--
 drivers/atm/solos-pci.c | 2 +-
 drivers/atm/zatm.c      | 8 +++++---
 6 files changed, 19 insertions(+), 14 deletions(-)

-- 
1.9.1
