From: Rusty Russell <rusty@rustcorp.com.au>
Subject: drivers/vhost: sizing of ubuf_info and heads
Date: Fri, 08 Mar 2013 13:57:09 +1100
Message-ID: <87hakmwqd6.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

Hi Michael,

        I'm a bit confused about why ubuf_info and heads are UIO_MAXIOV
length arrays, rather than being the size of the ring?  In particular,
this is suspicious:

linux/drivers/vhost/net.c:342:	struct ubuf_info *ubuf = &vq->ubuf_info[head];

And it seems to assume we trust head: a malicious guest could put the
same head entry in the ring twice, and we will get two callbacks on the
same value.  I don't know what that will do, but I'm not sure it's
harmless.

Thanks,
Rusty.
