From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the kselftest tree with the net-next
 tree
Date: Thu, 16 Feb 2017 14:24:53 +1100
Message-ID: <20170216142453.53d1f5e5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        "bamvor.zhangjian@huawei.com" <bamvor.zhangjian@huawei.com>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
To: Shuah Khan <shuahkh@osg.samsung.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Shuah,

Today's linux-next merge of the kselftest tree got a conflict in:

  tools/testing/selftests/bpf/Makefile

between commit:

  d498f8719a09 ("bpf: Rebuild bpf.o for any dependency update")

from the net-next tree and commit:

  88baa78d1f31 ("selftests: remove duplicated all and clean target")

from the kselftest tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc tools/testing/selftests/bpf/Makefile
index c7816fe60feb,058351b0694f..000000000000
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@@ -1,26 -1,7 +1,20 @@@
 -CFLAGS += -Wall -O2 -I../../../../usr/include
 +LIBDIR := ../../../lib
 +BPFOBJ := $(LIBDIR)/bpf/bpf.o
  
 -TEST_GEN_PROGS = test_verifier test_maps test_lru_map
 +CFLAGS += -Wall -O2 -lcap -I../../../include/uapi -I$(LIBDIR)
 +
- test_objs = test_verifier test_tag test_maps test_lru_map test_lpm_map
++TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map
  
- TEST_PROGS := $(test_objs) test_kmod.sh
- TEST_FILES := $(test_objs)
+ TEST_PROGS := test_kmod.sh
  
 +.PHONY: all clean force
 +
- all: $(test_objs)
- 
 +# force a rebuild of BPFOBJ when its dependencies are updated
 +force:
 +
 +$(BPFOBJ): force
 +	$(MAKE) -C $(dir $(BPFOBJ))
 +
 +$(test_objs): $(BPFOBJ)
 +
  include ../lib.mk
- 
- clean:
- 	$(RM) $(test_objs)
