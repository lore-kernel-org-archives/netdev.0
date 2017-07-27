From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Performance regression with virtio_net
Date: Fri, 28 Jul 2017 00:30:54 +0300
Message-ID: <20170728002913-mutt-send-email-mst@kernel.org>
References: <20170727170942.ub24lwgrl3x2outp@ubuntu-hedt>
	<20170727233244-mutt-send-email-mst@kernel.org>
	<20170727211430.viki2jcxbzk2u62c@ubuntu-hedt>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Seth Forshee <seth.forshee@canonical.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170727211430.viki2jcxbzk2u62c@ubuntu-hedt>
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

On Thu, Jul 27, 2017 at 04:14:30PM -0500, Seth Forshee wrote:
> On Thu, Jul 27, 2017 at 11:38:52PM +0300, Michael S. Tsirkin wrote:
> > On Thu, Jul 27, 2017 at 12:09:42PM -0500, Seth Forshee wrote:
> > > I'm seeing a performance regression with virtio_net that looks to have
> > > started in 4.12-rc1. I only see it in one context though, downloading
> > > snap packages from the Ubuntu snap store. For example:
> > > 
> > >  https://api.snapcraft.io/api/v1/snaps/download/b8X2psL1ryVrPt5WEmpYiqfr5emixTd7_1797.snap
> > > 
> > > which redirects to Internap's CDN. Normally this downloads in a few
> > > seconds at ~10 MB/s, but with 4.12 and 4.13 it takes minutes with a rate
> > > of ~150 KB/s. Everything else I've tried downloads as normal speeds.
> > 
> > So just wget that URL should be enough?
> 
> Yes. Note that sometimes it starts out faster then slows down.
> > > I bisected this to 680557cf79f8 "virtio_net: rework mergeable buffer
> > > handling". If I revert this on top of 4.13-rc2 (along with other changes
> > > needed to successfully revert it) speeds return to normal.
> > > 
> > > Thanks,
> > > Seth
> > 
> > 
> > Interesting. A more likely suspect would be
> > e377fcc8486d40867c6c217077ad0fa40977e060 - could you please try
> > reverting that one instead?
> 
> I tried it, and I still get slow download speeds. I did test at
> 680557cf79f82623e2c4fd42733077d60a843513 during the bisect so I'm
> reasonably confident that this is the one where things went bad.
> > Also, could you please look at mergeable_rx_buffer_size in sysfs with
> > and without the change?
> 
> In all cases (stock 4.13-rc2, 680557cf79f8 reverted, and e377fcc8486d
> reverted) mergeable_rx_buffer_size was 1536.
> 
> Thanks,
> Seth

Do you see any error counters incrementing after it slows down?

-- 
MST
