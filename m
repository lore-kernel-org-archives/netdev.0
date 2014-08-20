From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 0/8] Implement NAPI in et131x
Date: Wed, 20 Aug 2014 23:17:50 +0100
Message-ID: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Let's put a NAPI on this baby...

NAPI support was identified by Dave Miller <davem@davemloft.net> as a
must to get this driver out of staging. This patchset first tidies up
the code enough to make adding NAPI easier, and the final patch mostly
adds the 'boilerplate' NAPI code as described by:

http://www.linuxfoundation.org/collaborate/workgroups/networking/napi

The code has been tested on hardware, with no issues found to date.

**GregKH** - this patchset is based upon my previous bugfix 'Fix errors
caused by phydev->addr accesses' which is currently only on your
staging-linus branch, not staging-next - so won't apply cleanly in it's
current state. Please let me know if I need to do anything about this.

Cheers,

Mark

---
Mark Einon (8):
  staging: et131x: Use eth_mac_addr() instead of duplicating the
    functionality
  staging: et131x: Don't handle rx/tx packets when changing mtu
  staging: et131x: Use for loop to initialise contiguous registers to
    zero
  staging: et131x: Use for loop to initialise contiguous macstat
    registers to zero
  staging: et131x: Remove unnecessary i2c_wack variable
  staging: et131x: Rename NUM_PACKETS_HANDLED to MAX_PACKETS_HANDLED
  staging: et131x: Fix ET_INTR_TXDMA_ISR register name typo
  staging: et131x: Implement NAPI support

 drivers/staging/et131x/README   |   1 -
 drivers/staging/et131x/et131x.c | 271 ++++++++++------------------------------
 drivers/staging/et131x/et131x.h |  96 +-------------
 3 files changed, 69 insertions(+), 299 deletions(-)

-- 
2.1.0
