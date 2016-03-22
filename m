From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [PATCH v3 0/2] AF_VSOCK: Shrink the area influenced by prepare_to_wait
Date: Tue, 22 Mar 2016 17:05:50 +0100
Message-ID: <1458662752-2415-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Cc: labbott@fedoraproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset applies on net-next.

I think I found a problem with the patch submitted by Laura Abbott
( https://lkml.org/lkml/2016/2/4/711 ): we might miss wakeups.
Since the condition is not checked between the prepare_to_wait and the
schedule(), if a wakeup happens after the condition is checked but before
the sleep happens, and we miss it. ( A description of the problem can be
found here: http://www.makelinux.net/ldd3/chp-6-sect-2 ).

The first patch reverts the previous broken patch, while the second patch
properly fixes the sleep-while-waiting issue.


Claudio Imbrenda (2):
  Revert "vsock: Fix blocking ops call in prepare_to_wait"
  AF_VSOCK: Shrink the area influenced by prepare_to_wait

 net/vmw_vsock/af_vsock.c | 155 ++++++++++++++++++++++++++---------------------
 1 file changed, 87 insertions(+), 68 deletions(-)

-- 
1.9.1
