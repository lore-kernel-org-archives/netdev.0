From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH 1/3] driver core: enable drivers to use deferred probe
	from init
Date: Mon, 28 Jul 2014 20:48:58 +0200
Message-ID: <20140728184858.GK21930@wotan.suse.de>
References: <1406558067-25308-1-git-send-email-mcgrof@do-not-panic.com> <B5657A6538887040AD3A81F1008BEC63B06F9A@avmb3.qlogic.org> <20140728153811.GD21930@wotan.suse.de> <B5657A6538887040AD3A81F1008BEC63B06FCF@avmb3.qlogic.org> <B5657A6538887040AD3A81F1008BEC63B07066@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	"MPT-FusionLinux.pdl@avagotech.com"
	<MPT-Fusi
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B07066@avmb3.qlogic.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2014 at 06:30:29PM +0000, Yuval Mintz wrote:
> > On Mon, Jul 28, 2014 at 06:52:48PM +0200, Luis R. Rodriguez wrote:
> > > On Mon, Jul 28, 2014 at 03:46:32PM +0000, Yuval Mintz wrote:
> > > > Sorry for not being clear, but I didn't meant 'what guarantees that the device
> > > > will be added to the deferred probe', but rather what guarantees that the
> > > > deferred workqueue will be scheduled.
> > > >
> > > > To the best of my knowledge the deferring mechanism works only if one device
> > > > is dependent upon another, e.g., for Multi-function devices where one device
> > > > probe is dependent upon the others - which are soon-to-be probed.
> > >
> > > The workqueue will be kicked when driver_deferred_probe_trigger() gets
> > > poked, we do that in the late_initcall(deferred_probe_initcall), it
> > > also gets flushed there with a flush_workqueue(deferred_wq).
> 
> > But come to think of it that will work well for devices already plugged in
> > so indeed I think that driver_deferred_probe_add() needs a check added
> > for for if (!driver_deferred_probe_enable) then we have to
> > driver_deferred_probe_trigger(). The driver_deferred_probe_enable is set
> > to false upon init, but later on late init it gets set to true so with
> > that check we'd  only generate the trigger after late init call.
> 
> > I can fold that in the v2.
> 
> >   Luis
> 
> But what about modules being added after the init-calls? If they try try to use this
> mechanism, what guarantees they'll eventually get probed?

bus_probe_device --> device_attach() -->
	__device_attach() --> driver_probe_device() -->
		__driver_probe_device() --> driver_deferred_probe_add()

And with the new hunk I mentioned I'd add then we'd trigger the
workqueue if its after late init. The change is in v2 series.

  Luis
