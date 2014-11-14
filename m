From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 0/7] implementation of eBPF maps
Date: Thu, 13 Nov 2014 17:36:43 -0800
Message-ID: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

v1->v2:
renamed flags for MAP_UPDATE_ELEM command to be more concise,
clarified commit logs and improved comments in patches 1,3,7
per discussions with Daniel
 
Old v1 cover:

this set of patches adds implementation of HASH and ARRAY types of eBPF maps
which were described in manpage in commit b4fc1a460f30("Merge branch 'bpf-next'")

The difference vs previous version of these patches from August:
- added 'flags' attribute to BPF_MAP_UPDATE_ELEM
- in HASH type implementation removed per-map kmem_cache.
  I was doing kmem_cache_create() for every map to enable selective slub
  debugging to check for overflows and leaks. Now it's not needed, so just
  use normal kmalloc() for map elements.
- added ARRAY type which was mentioned in manpage, but wasn't public yet
- added map testsuite and removed temporary bits from test_stubs

Note, eBPF programs cannot be attached to events yet.
It will come in the next set.

Alexei Starovoitov (7):
  bpf: add 'flags' attribute to BPF_MAP_UPDATE_ELEM command
  bpf: add hashtable type of eBPF maps
  bpf: add array type of eBPF maps
  bpf: fix BPF_MAP_LOOKUP_ELEM command return code
  bpf: add a testsuite for eBPF maps
  bpf: allow eBPF programs to use maps
  bpf: remove test map scaffolding and user proper types

 include/linux/bpf.h         |    7 +-
 include/uapi/linux/bpf.h    |   13 +-
 kernel/bpf/Makefile         |    2 +-
 kernel/bpf/arraymap.c       |  151 ++++++++++++++++++
 kernel/bpf/hashtab.c        |  362 +++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/helpers.c        |   89 +++++++++++
 kernel/bpf/syscall.c        |    6 +-
 kernel/bpf/test_stub.c      |   56 ++-----
 samples/bpf/Makefile        |    3 +-
 samples/bpf/libbpf.c        |    3 +-
 samples/bpf/libbpf.h        |    2 +-
 samples/bpf/test_maps.c     |  291 ++++++++++++++++++++++++++++++++++
 samples/bpf/test_verifier.c |   14 +-
 13 files changed, 936 insertions(+), 63 deletions(-)
 create mode 100644 kernel/bpf/arraymap.c
 create mode 100644 kernel/bpf/hashtab.c
 create mode 100644 kernel/bpf/helpers.c
 create mode 100644 samples/bpf/test_maps.c

-- 
1.7.9.5
