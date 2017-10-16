From: Colin King <colin.king@canonical.com>
Subject: [PATCH] netfilter: ebtables: clean up initialization of buf
Date: Mon, 16 Oct 2017 11:24:02 +0100
Message-ID: <20171016102402.10358-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Florian Westphal <fw@strlen.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S . Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

buf is initialized to buf_start and then set on the next statement
to buf_start + offsets[i].  Clean this up to just initialize buf
to buf_start + offsets[i] to clean up the clang build warning:
"Value stored to 'buf' during its initialization is never read"

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/bridge/netfilter/ebtables.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 3b3dcf719e07..37817d25b63d 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -2112,9 +2112,8 @@ static int size_entry_mwt(struct ebt_entry *entry, const unsigned char *base,
 	for (i = 0, j = 1 ; j < 4 ; j++, i++) {
 		struct compat_ebt_entry_mwt *match32;
 		unsigned int size;
-		char *buf = buf_start;
+		char *buf = buf_start + offsets[i];
 
-		buf = buf_start + offsets[i];
 		if (offsets[i] > offsets[j])
 			return -EINVAL;
 
-- 
2.14.1
