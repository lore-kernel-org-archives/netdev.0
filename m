From: Andy King <acking@vmware.com>
Subject: [PATCH 4/4] VSOCK: Don't reject PF_VSOCK protocol
Date: Mon, 18 Feb 2013 08:04:13 -0800
Message-ID: <1361203453-1347-5-git-send-email-acking@vmware.com>
References: <1361203453-1347-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, Andy King <acking@vmware.com>, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1361203453-1347-1-git-send-email-acking@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Allow our own family as the protocol value for socket creation.

Reported-by: Gerd Hoffmann <kraxel@redhat.com>
Signed-off-by: Andy King <acking@vmware.com>
---
 net/vmw_vsock/af_vsock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index c1b9e55..ca511c4 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1860,7 +1860,7 @@ static int vsock_create(struct net *net, struct socket *sock,
 	if (!sock)
 		return -EINVAL;
 
-	if (protocol)
+	if (protocol && protocol != PF_VSOCK)
 		return -EPROTONOSUPPORT;
 
 	switch (sock->type) {
-- 
1.7.4.1
