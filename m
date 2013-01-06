From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 0/2] handle polling errors
Date: Sun,  6 Jan 2013 15:18:36 +0800
Message-ID: <1357456718-3072-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

This is an update version of last version to fix the handling of polling errors
in vhost/vhost_net.

Currently, vhost and vhost_net ignore polling errors which can lead kernel
crashing when it tries to remove itself from waitqueue after the polling
failure. Fix this by checking the poll->wqh before the removing and report an
error when meet polling errors.

Changes from v2:
- check poll->wqh instead of the wrong assumption about POLLERR and waitqueue
- drop the whole tx polling state check since it was replaced by the wqh
  checking
- drop the buggy tuntap patch

Changes from v1:
- restore the state before the ioctl when vhost_init_used() fails
- log the error when meet polling errors in the data path
- don't put into waitqueue when tun_chr_poll() return POLLERR

Jason Wang (2):
  vhost_net: correct error handling in vhost_net_set_backend()
  vhost: handle polling errors

 drivers/vhost/net.c   |   88 +++++++++++++++++++-----------------------------
 drivers/vhost/vhost.c |   31 +++++++++++++----
 drivers/vhost/vhost.h |    2 +-
 3 files changed, 59 insertions(+), 62 deletions(-)
