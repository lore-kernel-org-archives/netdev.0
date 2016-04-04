From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCHv2 net 1/3] samples/bpf: Fix build breakage with map_perf_test_user.c
Date: Mon,  4 Apr 2016 22:31:32 +0530
Message-ID: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S . Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building BPF samples is failing with the below error:

samples/bpf/map_perf_test_user.c: In function =E2=80=98main=E2=80=99:
samples/bpf/map_perf_test_user.c:134:9: error: variable =E2=80=98r=E2=80=
=99 has
initializer but incomplete type
  struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
         ^
samples/bpf/map_perf_test_user.c:134:21: error: =E2=80=98RLIM_INFINITY=E2=
=80=99
undeclared (first use in this function)
  struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
                     ^
samples/bpf/map_perf_test_user.c:134:21: note: each undeclared
identifier is reported only once for each function it appears in
samples/bpf/map_perf_test_user.c:134:9: warning: excess elements in
struct initializer [enabled by default]
  struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
         ^
samples/bpf/map_perf_test_user.c:134:9: warning: (near initialization
for =E2=80=98r=E2=80=99) [enabled by default]
samples/bpf/map_perf_test_user.c:134:9: warning: excess elements in
struct initializer [enabled by default]
samples/bpf/map_perf_test_user.c:134:9: warning: (near initialization
for =E2=80=98r=E2=80=99) [enabled by default]
samples/bpf/map_perf_test_user.c:134:16: error: storage size of =E2=80=98=
r=E2=80=99
isn=E2=80=99t known
  struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
                ^
samples/bpf/map_perf_test_user.c:139:2: warning: implicit declaration o=
f
function =E2=80=98setrlimit=E2=80=99 [-Wimplicit-function-declaration]
  setrlimit(RLIMIT_MEMLOCK, &r);
  ^
samples/bpf/map_perf_test_user.c:139:12: error: =E2=80=98RLIMIT_MEMLOCK=
=E2=80=99
undeclared (first use in this function)
  setrlimit(RLIMIT_MEMLOCK, &r);
            ^
samples/bpf/map_perf_test_user.c:134:16: warning: unused variable =E2=80=
=98r=E2=80=99
[-Wunused-variable]
  struct rlimit r =3D {RLIM_INFINITY, RLIM_INFINITY};
                ^
make[2]: *** [samples/bpf/map_perf_test_user.o] Error 1

=46ix this by including the necessary header file.

Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
v2: no changes

 samples/bpf/map_perf_test_user.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_te=
st_user.c
index 95af56e..3147377 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -17,6 +17,7 @@
 #include <linux/bpf.h>
 #include <string.h>
 #include <time.h>
+#include <sys/resource.h>
 #include "libbpf.h"
 #include "bpf_load.h"
=20
--=20
2.7.4
