From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH V2 net-next 1/6] test_bpf: avoid oopsing the kernel when generate_test_data() fails.
Date: Tue,  4 Aug 2015 15:19:07 +0200
Message-ID: <1438694352-17469-2-git-send-email-nschichan@freebox.fr>
References: <1438694352-17469-1-git-send-email-nschichan@freebox.fr>
Cc: Nicolas Schichan <nschichan@freebox.fr>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438694352-17469-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>

---
 lib/test_bpf.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 3afddf2..6843d0b 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4672,6 +4672,11 @@ static int run_one(const struct bpf_prog *fp, struct bpf_test *test)
 			break;
 
 		data = generate_test_data(test, i);
+		if (!data && !(test->aux & FLAG_NO_DATA)) {
+			pr_cont("data generation failed ");
+			err_cnt++;
+			break;
+		}
 		ret = __run_one(fp, data, runs, &duration);
 		release_test_data(test, data);
 
-- 
1.9.1
