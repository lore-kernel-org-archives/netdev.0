From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 0/7] implementation of eBPF maps
Date: Mon,  3 Nov 2014 18:54:09 -0800
Message-ID: <1415069656-14138-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

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
 include/uapi/linux/bpf.h    |   15 +-
 kernel/bpf/Makefile         |    2 +-
 kernel/bpf/arraymap.c       |  150 ++++++++++++++++++
 kernel/bpf/hashtab.c        |  362 +++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/helpers.c        |   88 +++++++++++
 kernel/bpf/syscall.c        |    6 +-
 kernel/bpf/test_stub.c      |   56 ++-----
 samples/bpf/Makefile        |    3 +-
 samples/bpf/libbpf.c        |    3 +-
 samples/bpf/libbpf.h        |    2 +-
 samples/bpf/test_maps.c     |  287 ++++++++++++++++++++++++++++++++++
 samples/bpf/test_verifier.c |   14 +-
 13 files changed, 932 insertions(+), 63 deletions(-)
 create mode 100644 kernel/bpf/arraymap.c
 create mode 100644 kernel/bpf/hashtab.c
 create mode 100644 kernel/bpf/helpers.c
 create mode 100644 samples/bpf/test_maps.c

-- 
1.7.9.5
