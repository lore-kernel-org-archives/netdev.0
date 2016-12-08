From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] linux/types.h: enable endian checks for all sparse builds
Date: Thu, 8 Dec 2016 04:29:39 +0200
Message-ID: <1481164052-28036-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, Neil Armstrong <narmstrong@baylibre.com>,
	David Airlie <airlied@linux.ie>, linux-remoteproc@vger.kernel.org,
	dri-devel@lists.freedesktop.org, virtualization@lists.linux-foundation.org,
	linux-s390@vger.kernel.org,
	"James E.J.  Bottomley" <jejb@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-scsi@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	Asias He <asias@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	linux-kbuild@vger.kernel.org, Jens Axboe <axboe@fb.com>,
	Michal Marek <mmarek@suse.com>, Stefan Hajnoczi <stefanha@redhat.com>,
	Matt Mackall <mpm@selenic.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

By now, linux is mostly endian-clean. Enabling endian-ness
checks for everyone produces about 200 new sparse warnings for me -
less than 10% over the 2000 sparse warnings already there.

Not a big deal, OTOH enabling this helps people notice
they are introducing new bugs.

So let's just drop __CHECK_ENDIAN__. Follow-up patches
can drop distinction between __bitwise and __bitwise__.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Suggested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Linus, could you ack this for upstream? If yes I'll
merge through my tree as a replacement for enabling
this just for virtio.

 include/uapi/linux/types.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/uapi/linux/types.h b/include/uapi/linux/types.h
index acf0979..41e5914 100644
--- a/include/uapi/linux/types.h
+++ b/include/uapi/linux/types.h
@@ -23,11 +23,7 @@
 #else
 #define __bitwise__
 #endif
-#ifdef __CHECK_ENDIAN__
 #define __bitwise __bitwise__
-#else
-#define __bitwise
-#endif
 
 typedef __u16 __bitwise __le16;
 typedef __u16 __bitwise __be16;
-- 
MST
