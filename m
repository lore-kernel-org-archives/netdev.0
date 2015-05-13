From: Amir Vadai <amirv@mellanox.com>
Subject: dma_alloc_coherent() to use memory close to cpu
Date: Wed, 13 May 2015 15:40:57 +0300
Message-ID: <55534659.9000606@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <achiad@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0085.outbound.protection.outlook.com ([157.56.112.85]:2800
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934250AbbEMMmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 08:42:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

dma_alloc_coherent() is allocating memory close to the device -
according to dev_to_node(dev). Sometimes it is better to use memory
close to the CPU. e.g. when it is a buffer that NIC writes and CPU reads.

It seems that you thought that too, and added a commit to ixgbe driver
that follows that logic [1].
You added calls to set_dev_node() before and after the allocation.
This seems to be prone to races in case multiple process want to alloc
in parallel. The proper fix seems to be to extend the
dma_alloc_coherent() to accept a NUMA node as an argument (if device's
node is not good enough).

I looked for, but couldn't find any discussion about that - is there a
special reason not to extend dma_alloc_coherent()?

[1] - de88eee ("ixgbe: Allocate rings as part of the q_vector")

Thanks,
Amir
