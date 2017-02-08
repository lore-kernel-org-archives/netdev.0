From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v4 00/11] Improve BPF selftests and use the library (net-next tree)
Date: Wed,  8 Feb 2017 21:49:29 +0100
Message-ID: <20170208204940.26023-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series brings some fixes to selftests, add the ability to test
unprivileged BPF programs as root and replace bpf_sys.h with calls to the BPF
library.

This is intended for the net-next tree and apply on d9e1661dab02 ("Merge branch
'mlxsw-Reflect-nexthop-status-changes'").

Changes since v3:
* keep the bzero() calls

Changes since v2:
* use the patches from two previous series (unprivileged tests and bpf_sys.h
  replacement)
* include one more stdint.h
* rebase on net-next
* add this cover letter

Changes since v1:
* exclude patches not intended for the net-next tree

Regards,

Mickaël Salaün (11):
  tools: Sync {,tools/}include/uapi/linux/bpf.h
  bpf: Change the include directory for selftest
  bpf: Always test unprivileged programs
  bpf: Use bpf_load_program() from the library
  bpf: Use bpf_map_update_elem() from the library
  bpf: Use bpf_map_lookup_elem() from the library
  bpf: Use bpf_map_delete_elem() from the library
  bpf: Use bpf_map_get_next_key() from the library
  bpf: Use bpf_create_map() from the library
  bpf: Remove bpf_sys.h from selftests
  bpf: Add test_tag to .gitignore

 tools/include/uapi/linux/bpf.h              |  23 +++-
 tools/lib/bpf/bpf.c                         |  20 ++--
 tools/lib/bpf/bpf.h                         |  12 +--
 tools/testing/selftests/bpf/.gitignore      |   1 +
 tools/testing/selftests/bpf/Makefile        |   4 +-
 tools/testing/selftests/bpf/bpf_sys.h       | 108 -------------------
 tools/testing/selftests/bpf/test_lpm_map.c  |  38 +++----
 tools/testing/selftests/bpf/test_lru_map.c  | 106 +++++++++----------
 tools/testing/selftests/bpf/test_maps.c     | 158 ++++++++++++++--------------
 tools/testing/selftests/bpf/test_tag.c      |  11 +-
 tools/testing/selftests/bpf/test_verifier.c |  84 ++++++++++++---
 11 files changed, 274 insertions(+), 291 deletions(-)
 delete mode 100644 tools/testing/selftests/bpf/bpf_sys.h

-- 
2.11.0
