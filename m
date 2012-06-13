From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Subject: [PATCH 0/5] Introduce generic set_bit_le() -v2
Date: Wed, 13 Jun 2012 13:00:54 +0900
Message-ID: <20120613130054.b5695621.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, grundler@parisc-linux.org,
	arnd@arndb.de, benh@kernel.crashing.org, avi@redhat.com,
	mtosatti@redhat.com, linux-net-drivers@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, kvm@vger.kernel.org,
	takuya.yoshikawa@gmail.com
To: akpm@linux-foundation.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  [ Andrew, can you take this or should I send to other person?
    Note: the whole series is against linux-next. ]

KVM is using test_and_set_bit_le() for this missing function; this patch
series corrects this usage.

As some drivers have their own definitions of set_bit_le(), a bit of
preparation is also needed.

  Although these are differently implemented, especially for big-endian
  case, than the generic __set_bit_le(), it should not be a problem to
  use the latter since both maintainers prefer it.

Changes from v1:
  - sfc:     Ben made a patch
  - tulip:   followed suggestion by Grant
  - bitops:  added clear_bit_le -- suggested by Arnd
  - powerpc: added the same code


Ben Hutchings (1):
  sfc: Use standard __{clear,set}_bit_le() functions

Takuya Yoshikawa (4):
  drivers/net/ethernet/dec/tulip: Use standard __set_bit_le() function
  bitops: Introduce generic {clear,set}_bit_le()
  powerpc: bitops: Introduce {clear,set}_bit_le()
  KVM: Replace test_and_set_bit_le() in mark_page_dirty_in_slot() with set_bit_le()

 arch/powerpc/include/asm/bitops.h           |   10 ++++++++++
 drivers/net/ethernet/dec/tulip/de2104x.c    |    7 ++-----
 drivers/net/ethernet/dec/tulip/tulip_core.c |    7 ++-----
 drivers/net/ethernet/sfc/efx.c              |    4 ++--
 drivers/net/ethernet/sfc/net_driver.h       |   12 ------------
 drivers/net/ethernet/sfc/nic.c              |    4 ++--
 include/asm-generic/bitops/le.h             |   10 ++++++++++
 virt/kvm/kvm_main.c                         |    3 +--
 8 files changed, 29 insertions(+), 28 deletions(-)

-- 
1.7.5.4

