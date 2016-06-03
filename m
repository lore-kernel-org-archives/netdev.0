From: Helge Deller <deller@gmx.de>
Subject: [PATCH] soreuseport: Fix reuseport_bpf testcase on 32bit
 architectures
Date: Fri, 3 Jun 2016 19:19:20 +0200
Message-ID: <20160603171920.GB3664@ls3530.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-parisc@vger.kernel.org
To: Craig Gallek <kraig@google.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the following compiler warnings when compiling the
reuseport_bpf testcase on a 32 bit platform:

reuseport_bpf.c: In function =E2=80=98attach_ebpf=E2=80=99:
reuseport_bpf.c:114:15: warning: cast from pointer to integer of iffere=
nt size [-Wpointer-to-int-cast]

Signed-off-by: Helge Deller <deller@gmx.de>

diff --git a/tools/testing/selftests/net/reuseport_bpf.c b/tools/testin=
g/selftests/net/reuseport_bpf.c
index 96ba386..4a82174 100644
--- a/tools/testing/selftests/net/reuseport_bpf.c
+++ b/tools/testing/selftests/net/reuseport_bpf.c
@@ -111,9 +111,9 @@ static void attach_ebpf(int fd, uint16_t mod)
 	memset(&attr, 0, sizeof(attr));
 	attr.prog_type =3D BPF_PROG_TYPE_SOCKET_FILTER;
 	attr.insn_cnt =3D ARRAY_SIZE(prog);
-	attr.insns =3D (uint64_t)prog;
-	attr.license =3D (uint64_t)bpf_license;
-	attr.log_buf =3D (uint64_t)bpf_log_buf;
+	attr.insns =3D (unsigned long) &prog;
+	attr.license =3D (unsigned long) &bpf_license;
+	attr.log_buf =3D (unsigned long) &bpf_log_buf;
 	attr.log_size =3D sizeof(bpf_log_buf);
 	attr.log_level =3D 1;
 	attr.kern_version =3D 0;
@@ -351,8 +351,8 @@ static void test_filter_no_reuseport(const struct t=
est_params p)
 	memset(&eprog, 0, sizeof(eprog));
 	eprog.prog_type =3D BPF_PROG_TYPE_SOCKET_FILTER;
 	eprog.insn_cnt =3D ARRAY_SIZE(ecode);
-	eprog.insns =3D (uint64_t)ecode;
-	eprog.license =3D (uint64_t)bpf_license;
+	eprog.insns =3D (unsigned long) &ecode;
+	eprog.license =3D (unsigned long) &bpf_license;
 	eprog.kern_version =3D 0;
=20
 	memset(&cprog, 0, sizeof(cprog));
--
To unsubscribe from this list: send the line "unsubscribe linux-parisc"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
