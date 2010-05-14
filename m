From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 00/25] WiMAX pull request
Date: Fri, 14 May 2010 14:44:59 -0700
Message-ID: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>

There are no new features driver wise -- this is all a set of bug
fixes, mostly small ones, some bigger:

 - TX FIFO handling had a few more corner cases Q&A found

   fix incorrect return -ESHUTDOWN when there is no Tx buffer available
   fix the race condition for accessing TX queue
   add the error recovery mechanism on TX path
   Reset the TX FIFO indices when allocating the TX FIFO in tx_setup()
   increase the maximum number of payloads per message to 60 [v1]
   limit the message size upto 16KiB [v1]
   modify i2400m_tx_fifo_push() to check for head room space in the TX FIFO [v1]
   fix system freeze caused by an infinite loop [v1]
   reserve additional space in the TX queue's buffer while allocating space for a new message header

 - RX chain

   fix incorrect handling of type 2 and 3 RX messages
   fix race condition while accessing rx_roq by using kref count

 - SDIO reset handling: work out quirks

 - Small rearrangements to reduce forward declarations

NOTE: the WiMAX tree in
git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git has been
rebased, so if you were tracking it, you will need to do a hard
pull. Sorry for that.

The reason this has been done is that wimax.git/master will now
stable, no cherry picking and always chasing net-next-2.6 /
net-2.6. The old wimax/master tree was thus unfeasible for upstream
pull as it was quite contaminated with extraenous commits.

When net-2.6 opens, wimax/2.6.X opens chasing net-2.6, later it will
chase linux-allstable-2.6/linux-2.6.X.y if need be when the kernel
release happens.


The following changes since commit 2b0b05ddc04b6d45e71cd36405df512075786f1e:
  Marcel Holtmann (1):
        Bluetooth: Fix issues where sk_sleep() helper is needed now

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git master

Patches follow for reviewing convenience.

Cindy H Kao (6):
      wimax/i2400m: fix the race condition for accessing TX queue
      wimax/i2400m: correct the error path handlers in dev_start()
      wimax/i2400m: fix for missed reset events if triggered by dev_reset_handle()
      wimax/i2400m: add the error recovery mechanism on TX path
      wimax/i2400m: Correct the error path handlers order in i2400m_post_reset()
      wimax/i2400m: Reset the TX FIFO indices when allocating the TX FIFO in tx_setup()

Dan Carpenter (2):
      wimax: checking ERR_PTR vs null
      wimax: wimax_msg_alloc() returns ERR_PTR not null

Inaky Perez-Gonzalez (2):
      wimax/i2400m: driver defaults to firmware v1.5 for i5x50 devices
      wimax/i2400m: driver defaults to firmware v1.5 for i6x60 devices

Prasanna S Panchamukhi (1):
      wimax/i2400m: Move module params to other file so they can be static

Prasanna S. Panchamukhi (13):
      wimax/i2400m: move I2400M_MAX_MTU enum from netdev.c to i2400m.h
      wimax/i2400m: fix insufficient size of Tx buffer for 12 payload of 1400 MTU.
      wimax/i2400m: increase the maximum number of payloads per message to 60 [v1]
      wimax/i2400m: limit the message size upto 16KiB [v1]
      wimax/i2400m: fix BUILD_BUG_ON() to use the maximum message size constant [v1]
      wimax/i2400m: modify i2400m_tx_fifo_push() to check for head room space in the TX FIFO [v1]
      wimax/i2400m: fix system freeze caused by an infinite loop [v1]
      wimax/i2400m: increase tx queue length from 5 to 20 [v1]
      wimax i2400m: fix race condition while accessing rx_roq by using kref count
      wimax/i2400m: fix incorrect handling of type 2 and 3 RX messages
      wimax/i2400m: reserve additional space in the TX queue's buffer while allocating space for a new message header
      wimax/i2400m: SDIO specific TX queue's minimum buffer room for new message
      wimax/i2400m: USB specific TX queue's minimum buffer room required for new message

Prasanna S.Panchamukhi (1):
      wimax/i2400m: fix incorrect return -ESHUTDOWN when there is no Tx buffer available

 drivers/net/wimax/i2400m/control.c     |   15 +++
 drivers/net/wimax/i2400m/driver.c      |  165 +++++++++++++++++++++++++-------
 drivers/net/wimax/i2400m/i2400m-sdio.h |    5 +-
 drivers/net/wimax/i2400m/i2400m.h      |   82 ++++++++++++++--
 drivers/net/wimax/i2400m/netdev.c      |   12 +--
 drivers/net/wimax/i2400m/rx.c          |  109 ++++++++++++++-------
 drivers/net/wimax/i2400m/sdio-tx.c     |   35 ++++++--
 drivers/net/wimax/i2400m/sdio.c        |    7 ++
 drivers/net/wimax/i2400m/tx.c          |  153 ++++++++++++++++++++++++++----
 drivers/net/wimax/i2400m/usb.c         |   12 ++-
 net/wimax/stack.c                      |    2 +-
 11 files changed, 480 insertions(+), 117 deletions(-)
