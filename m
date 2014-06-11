From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: infrastructure changes for 3.16
Date: Wed, 11 Jun 2014 16:44:47 +0300
Message-ID: <20140611134447.GA8208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-scsi@vger.kernel.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, nab@daterainc.com
To: Linus Torvalds <torvalds@linux-foundation.org>
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

Hi Linus,
Please pull the following.
Please note this needs to be merged before merging
target-pending PULL which Nicholas will be sending
out shortly.

Thanks!

The following changes since commit 1860e379875dfe7271c649058aeddffe5afd9d0d:

  Linux 3.15 (2014-06-08 11:19:54 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 47283bef7ed356629467d1fac61687756e48f254:

  vhost: move memory pointer to VQs (2014-06-09 16:21:07 +0300)

----------------------------------------------------------------
vhost: infrastructure changes for 3.16

This reworks vhost core dropping unnecessary RCU uses in favor of VQ mutexes
which are used on fast path anyway.  This fixes worst-case latency for users
which change the memory mappings a lot.
Memory allocation for vhost-net now supports fallback on vmalloc (same as for
vhost-scsi) this makes it possible to create the device on systems where memory
is very fragmented, with slightly lower performance.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Michael S. Tsirkin (4):
      vhost-net: extend device allocation to vmalloc
      vhost: replace rcu with mutex
      vhost: move acked_features to VQs
      vhost: move memory pointer to VQs

 drivers/vhost/vhost.h | 19 ++++------
 drivers/vhost/net.c   | 35 ++++++++++++-------
 drivers/vhost/scsi.c  | 26 ++++++++------
 drivers/vhost/test.c  | 11 +++---
 drivers/vhost/vhost.c | 97 ++++++++++++++++++++++++++-------------------------
 5 files changed, 101 insertions(+), 87 deletions(-)
