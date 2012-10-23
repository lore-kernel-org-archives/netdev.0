From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7-rc2 regression : file copied to CIFS-mounted directory
 corrupted
Date: Tue, 23 Oct 2012 08:08:48 +0200
Message-ID: <1350972528.8609.1431.camel@edumazet-glaptop>
References: <22207427.56211350970373630.JavaMail.weblogic@epml04>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"edumazet@google.com" <edumazet@google.com>
To: jongman.heo@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <22207427.56211350970373630.JavaMail.weblogic@epml04>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-10-23 at 05:38 +0000, Jongman Heo wrote:
> Hmm,
> 
> I've just met the issue, with the commit 5640f768 reverted.
> It seems that the issue does not always happen. So, my bisection may not be correct.
> 
> At this moment, I don't have enough time to do bisection again..
> 
> Regards.

What happens, if instead of reverting you try the following ?

If this solves the problem, then we shall find the driver that assumes
frags are order-0 pages only.

diff --git a/net/core/sock.c b/net/core/sock.c
index 8a146cf..a743e7c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1726,7 +1726,7 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
 /* On 32bit arches, an skb frag is limited to 2^15 */
-#define SKB_FRAG_PAGE_ORDER	get_order(32768)
+#define SKB_FRAG_PAGE_ORDER	0
 
 bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
 {
