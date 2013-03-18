From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 0/2] Address issues in dma-debug API
Date: Mon, 18 Mar 2013 15:12:38 -0700
Message-ID: <20130318220241.7349.5030.stgit@ahduyck-cp1.jf.intel.com>
References: <3729150.HPUjKjXiGc@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: konrad.wilk@oracle.com, joerg.roedel@amd.com, konrad@kernel.org,
	christoph.paasch@uclouvain.be, mingo@redhat.com,
	shuahkhan@gmail.com, hpa@zytor.com, akpm@linux-foundation.org,
	shuah.khan@hp.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3729150.HPUjKjXiGc@cpaasch-mac>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Paasch recently reported a "device driver failed to check map 
error" on igb.  However after reviewing the code there was no possibility of
that.  On closer inspection there was a bug in the DMA debug API that was
causing the issue.  These two patches address the issues I found.

The first issue I found while trying to implement a workaround.  Specifically
the problem is a locking bug which is triggered if a multiple mapped buffer
exists and there is not an exact match for the unmap.  This results in the CPU
becoming deadlocked.

The second issue, which was the original problem, is resolved by guaranteeing
that if we call dma_mapping_error we set a matching entry to MAP_ERR_CHECKED
that was not previously set. 

I'm not sure if these are critical enough to go into one of the upcoming RC
kernels or if these can wait until the merge since this is in a debugging API.
I'm leaving that for the sub-maintainers to decide.

---

Alexander Duyck (2):
      dma-debug: Fix locking bug in check_unmap
      dma-debug: Update DMA debug API to better handle multiple mappings of a buffer


 lib/dma-debug.c |   42 ++++++++++++++++++++++++++++--------------
 1 files changed, 28 insertions(+), 14 deletions(-)

-- 
