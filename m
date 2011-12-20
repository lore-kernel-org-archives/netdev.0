From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] virtio_net: fix refill related races
Date: Tue, 20 Dec 2011 21:09:08 +0200
Message-ID: <20111220190908.GC25689@redhat.com>
References: <20111207152120.GA23417@redhat.com>
	<8739cvisqe.fsf@rustcorp.com.au>
	<20111211144428.GB14381@redhat.com>
	<878vmioh10.fsf@rustcorp.com.au> <20111212115405.GB7946@redhat.com>
	<87iplltd0g.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87iplltd0g.fsf@rustcorp.com.au>
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

On Tue, Dec 13, 2011 at 01:05:11PM +1030, Rusty Russell wrote:
> On Mon, 12 Dec 2011 13:54:06 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > On Mon, Dec 12, 2011 at 09:25:07AM +1030, Rusty Russell wrote:
> > > Orthogonally, the refill-stop code is still buggy, as you noted.
> > 
> > Sorry I don't understand how it's still buggy.
> 
> Both places where we call:
> 
> 	cancel_delayed_work_sync(&vi->refill);
> 
> Do not actually guarantee that vi->refill isn't running, because it
> can requeue itself.  A 'bool no_more_refill' field seems like the
> simplest fix for this, but I don't think it's sufficient.
> 
> Tejun, is this correct?  What's the correct way to synchronously stop a
> delayed_work which can "schedule_delayed_work(&vi->refill, HZ/2);" on
> itself?
> 
> Thanks,
> Rusty.

Another question, wanted to make sure:
virtnet_poll does schedule_delayed_work(&vi->refill, 0);
separately refill work itself also does
schedule_delayed_work(&vi->refill, HZ/2);
If two such events happen twice, on different CPUs, we are still guaranteed
the work will only run once, right?
