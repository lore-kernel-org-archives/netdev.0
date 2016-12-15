From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/8] enable endian checks for all sparse builds
Date: Thu, 15 Dec 2016 07:15:06 +0200
Message-ID: <1481778865-27667-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, Neil Armstrong <narmstrong@baylibre.com>,
	David Airlie <airlied@linux.ie>, linux-remoteproc@vger.kernel.org,
	dri-devel@lists.freedesktop.org, virtualization@lists.linux-foundation.org,
	Matthias Brugger <matthias.bgg@gmail.com>, linux-s390@vger.kernel.org,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, linux-scsi@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	v9fs-developer@lists.sourceforge.net,
	Asias He <asias@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	linux-kbuild@vger.kernel.org, Jens Axboe <axboe@fb.com>,
	Michal Marek <mmarek@suse.com>, linux-mediatek@lists.infradead.org,
	Stefan Hajnoczi <stefanha@redhat.com>, Matt Mackall <mpm@selenic.com>,
	linux-arm-kernel@lists.infradead.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torv
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is just a reposting of the patch that enables endian checks, with addition
of trivial patches that drop __bitwise__ and __CHECK_ENDIAN__ everywhere.

I plan to include this in my pull request unless I hear otherwise.

Michael S. Tsirkin (8):
  linux/types.h: enable endian checks for all sparse builds
  tools: enable endian checks for all sparse builds
  Documentation/sparse: drop __bitwise__
  checkpatch: replace __bitwise__ with __bitwise
  linux: drop __bitwise__ everywhere
  Documentation/sparse: drop __CHECK_ENDIAN__
  fs/logfs: drop __CHECK_ENDIAN__
  Makefile: drop -D__CHECK_ENDIAN__ from cflags

 Documentation/translations/zh_CN/sparse.txt               |  7 +------
 arch/arm/plat-samsung/include/plat/gpio-cfg.h             |  2 +-
 drivers/md/dm-cache-block-types.h                         |  6 +++---
 drivers/net/ethernet/sun/sunhme.h                         |  2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h          |  4 ++--
 fs/logfs/logfs.h                                          |  4 +---
 include/linux/mmzone.h                                    |  2 +-
 include/linux/serial_core.h                               |  4 ++--
 include/linux/types.h                                     |  4 ++--
 include/scsi/iscsi_proto.h                                |  2 +-
 include/target/target_core_base.h                         |  2 +-
 include/uapi/linux/types.h                                |  4 ----
 include/uapi/linux/virtio_types.h                         |  6 +++---
 net/ieee802154/6lowpan/6lowpan_i.h                        |  2 +-
 net/mac80211/ieee80211_i.h                                |  4 ++--
 tools/include/linux/types.h                               |  4 ----
 Documentation/dev-tools/sparse.rst                        | 14 +-------------
 drivers/bluetooth/Makefile                                |  2 --
 drivers/net/can/Makefile                                  |  1 -
 drivers/net/ethernet/altera/Makefile                      |  1 -
 drivers/net/ethernet/atheros/alx/Makefile                 |  1 -
 drivers/net/ethernet/freescale/Makefile                   |  2 --
 drivers/net/wireless/ath/Makefile                         |  2 --
 drivers/net/wireless/ath/wil6210/Makefile                 |  2 --
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/Makefile |  2 --
 drivers/net/wireless/broadcom/brcm80211/brcmsmac/Makefile |  1 -
 drivers/net/wireless/intel/iwlegacy/Makefile              |  2 --
 drivers/net/wireless/intel/iwlwifi/Makefile               |  2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/Makefile           |  2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/Makefile           |  2 +-
 drivers/net/wireless/intersil/orinoco/Makefile            |  3 ---
 drivers/net/wireless/mediatek/mt7601u/Makefile            |  2 --
 drivers/net/wireless/realtek/rtlwifi/Makefile             |  2 --
 drivers/net/wireless/realtek/rtlwifi/btcoexist/Makefile   |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/Makefile   |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192c/Makefile    |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/Makefile   |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/Makefile   |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/Makefile   |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/Makefile   |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/Makefile   |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/Makefile   |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/Makefile   |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8723com/Makefile  |  2 --
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/Makefile   |  2 --
 drivers/net/wireless/ti/wl1251/Makefile                   |  2 --
 drivers/net/wireless/ti/wlcore/Makefile                   |  2 --
 drivers/staging/rtl8188eu/Makefile                        |  2 +-
 drivers/staging/rtl8192e/Makefile                         |  2 --
 drivers/staging/rtl8192e/rtl8192e/Makefile                |  2 --
 net/bluetooth/Makefile                                    |  2 --
 net/ieee802154/Makefile                                   |  2 --
 net/mac80211/Makefile                                     |  2 +-
 net/mac802154/Makefile                                    |  2 --
 net/wireless/Makefile                                     |  2 --
 scripts/checkpatch.pl                                     |  4 ++--
 56 files changed, 30 insertions(+), 120 deletions(-)

-- 
MST
