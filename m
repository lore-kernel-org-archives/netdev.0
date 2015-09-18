From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 0/1] macvtap regression since 3.18
Date: Fri, 18 Sep 2015 09:54:43 +0200
Message-ID: <1442562884-27310-1-git-send-email-borntraeger@de.ibm.com>
Cc: stable@vger.kernel.org, netdev@vger.kernel.org,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
	kvm@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,

here is a fixup for macvtap. It was detected by running
several different patterns via uperf over multiple network
cards. Within some minutes, the network traffic stalled
and Matt bisected it down to 39ec7de7092b ("macvtap: fix
uninitialized access on TUNSETIFF"). Turns out that
this patch broke sndbuf setting. I dont know exactly what
went wrong in that testcase, but an earlier version of
the patch did the trick and the testcase is now stable
again.

I was tempted to add another variable, but u,up,s,sp seem
to have a meaning (signed,signed pointer) so I  made u
an unsigned int again. Long term we might want to refactor
the code to have 

int sk_sendbuf;
short ifr_flags;
int vnet_hdr_sz;

or something like that. But this rework would be to big
for stable.

Some of the casts that I added are not strictly necessary
as get/put_user already do this, but better safe than
sorry as we dont want to rely on the implementation of
macros. Opinions?


Christian Borntraeger (1):
  macvtap: Fix regression for macvtap ioctls

 drivers/net/macvtap.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

-- 
2.3.0

