From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] virtio_net: fix refill related races
Date: Tue, 20 Dec 2011 11:09:46 -0800
Message-ID: <20111220190946.GD10752@google.com>
References: <20111207152120.GA23417@redhat.com>
	<8739cvisqe.fsf@rustcorp.com.au>
	<20111211144428.GB14381@redhat.com>
	<878vmioh10.fsf@rustcorp.com.au> <20111212115405.GB7946@redhat.com>
	<87iplltd0g.fsf@rustcorp.com.au>
	<20111220190908.GC25689@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111220190908.GC25689@redhat.com>
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

Hello, Michael.

On Tue, Dec 20, 2011 at 09:09:08PM +0200, Michael S. Tsirkin wrote:
> Another question, wanted to make sure:
> virtnet_poll does schedule_delayed_work(&vi->refill, 0);
> separately refill work itself also does
> schedule_delayed_work(&vi->refill, HZ/2);
> If two such events happen twice, on different CPUs, we are still guaranteed
> the work will only run once, right?

No, it's not.  Normal workqueues only guarantee non-reentrance on
local CPU.  If you want to guarantee that only one instance of a given
item is executing across all CPUs, you need to use the nrt workqueue.

Thanks.

-- 
tejun
