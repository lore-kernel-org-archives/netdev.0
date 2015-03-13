From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] 9p/trans_virtio: fix hot-unplug
Date: Fri, 13 Mar 2015 11:54:30 +1030
Message-ID: <8761a5wuy9.fsf@rustcorp.com.au>
References: <20150309154814-mutt-send-email-mst@redhat.com>
	<874mprxb2d.fsf@rustcorp.com.au>
	<20150312073545-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Van Hensbergen <ericvh@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	v9fs-developer@lists.sourceforge.net, Ron Minnich <rminnich@sandia.gov>,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150312073545-mutt-send-email-mst@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Thu, Mar 12, 2015 at 11:54:10AM +1030, Rusty Russell wrote:
>> "Michael S. Tsirkin" <mst@redhat.com> writes:
>> > On device hot-unplug, 9p/virtio currently will kfree channel while
>> > it might still be in use.
>> >
>> > Of course, it might stay used forever, so it's an extremely ugly hack,
>> > but it seems better than use-after-free that we have now.
>> >
>> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> 
>> I'll apply it, but it looks like a bandaid.
>
>
> Absolutely.

Applied this, too:


Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 73fab71397ce..781315d97ed5 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -659,7 +659,6 @@ static void p9_virtio_remove(struct virtio_device *vdev)
 {
 	struct virtio_chan *chan = vdev->priv;
 	unsigned long warning_time;
-	bool inuse;
 
 	mutex_lock(&virtio_9p_lock);
