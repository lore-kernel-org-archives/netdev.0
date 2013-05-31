From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc V2 0/8] Multiqueue API for macvtap
Date: Fri, 31 May 2013 17:53:17 +0800
Message-ID: <1369994005-5943-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

This series implements a v2 of fully tuntap compatiable API which could be used
by userspace to manage multiple macvtap queues. The main parts is to add
TUNSETQUEUE ioctl support for macvtap.

Patch 1 - 4 was some tuntap compatibility and misc cleanups.
Patch 5 removes the linear search in macvtap by reshuffling the macvtaps array
each time a queue is removed. After this, we could store both enabled and
disabled queues in the same array without introducing extra data structure.
Patch 6 let TUNSETIFF can create multiqueue device, nothing but some check
were added.
Patch 7 implement TUNSETQUEUE ioctl
Patch 8 reports IFF_MULTI_QUEUE to userspace to notify the userspace that the
multiqueue API is completed.

Flow caches implememtation were missed in this version, since I am doing
rework on the tuntap flow caches. Have some some stress test with both netperf
and pktgen.

Please review, thanks.

Changes from V1:
- Drop the patch of "return -EBADFD when TUNGETIFF fails" to preserve backward
  compatibility
- Add a small patch of optimizing macvtap_do_read() (see patch 1/8)
- Use different functions to do tap enabling and creating
- Use different functions to do tap disabling and closing
- Remove the emtpy line in patch 6/8
- Add a line in patch 3/8
- Add a comment to explain the checking when doing TUNSETIFF with
  IFF_MULTI_QUEUE
- Add comments to explian the second swapping when moving taps between disabled
  areas and enabled areas.
- Fix the commit log of patch 7/8 ( v1 says the linked list were used which is
  wrong )
- Other minor bug fixes

Jason Wang (8):
  macvtap: do not add self to waitqueue if doing a nonblock read
  macvlan: switch to use IS_ENABLED()
  macvtap: introduce macvtap_get_vlan()
  macvlan: change the max number of queues to 16
  macvtap: eliminate linear search
  macvtap: allow TUNSETIFF to create multiqueue device
  macvtap: add TUNSETQUEUE ioctl
  macvtap: enable multiqueue flag

 drivers/net/macvtap.c      |  292 +++++++++++++++++++++++++++++++++----------
 include/linux/if_macvlan.h |   11 ++-
 2 files changed, 233 insertions(+), 70 deletions(-)
