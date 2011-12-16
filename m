From: zanghongyong@huawei.com
Subject: [PATCH 0/2] vhot-net: Use kvm_memslots instead of vhost_memory to
 translate GPA to HVA
Date: Fri, 16 Dec 2011 13:32:06 +0800
Message-ID: <1324013528-3663-1-git-send-email-zanghongyong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Cc: mst@redhat.com, levinsasha928@gmail.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	xiaowei.yang@huawei.com, hanweidong@huawei.com,
	wusongwei@huawei.com, Hongyong Zang <zanghongyong@huawei.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hongyong Zang <zanghongyong@huawei.com>

Vhost-net uses its own vhost_memory, which results from user space (qemu) info,
to translate GPA to HVA. Since kernel's kvm structure already maintains the 
address relationship in its member *kvm_memslots*, these patches use kernel's 
kvm_memslots directly without the need of initialization and maintenance of 
vhost_memory.

Hongyong Zang (2):
  kvm: Introduce get_kvm_from_task
  vhost-net: Use kvm_memslots for address translation

 drivers/vhost/vhost.c    |   53 +++++++++++++++++----------------------------
 include/linux/kvm_host.h |    2 +-
 virt/kvm/kvm_main.c      |   13 +++++++++++
 3 files changed, 34 insertions(+), 34 deletions(-)
