From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Fri, 5 Sep 2014 19:35:30 +0200
Message-ID: <20140905173529.GB17986@wotan.suse.de>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com> <1409899047-13045-4-git-send-email-mcgrof@do-not-panic.com> <20140905105949.GA22778@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	falcon@meizu.com, tiwai@suse.de, tj@kernel.org,
	arjan@linux.intel.com, linux-kernel@vger.kernel.org, hare@suse.com,
	akpm@linux-foundation.org, penguin-kernel@i-love.sakura.ne.jp,
	joseph.salisbury@canonical.com, bpoirier@suse.de,
	santosh@chelsio.com, Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netd
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140905105949.GA22778@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 05, 2014 at 12:59:49PM +0200, Oleg Nesterov wrote:
> On 09/04, Luis R. Rodriguez wrote:
> >
> > From: "Luis R. Rodriguez" <mcgrof@suse.com>
> >
> > The new umh kill option has allowed kthreads to receive
> > kill signals but they are generally accepting all sources
> > of kill signals
> 
> And I think this is right,
> 
> > while the original motivation was to enable
> > through the OOM from sending the kill.
> 
> even if the main concern was OOM.
> 
> > Users can provide a log output and it should be clear on
> > the trace what probe / driver got the kill signal.
> 
> Well, if you need a WARN output, perhaps you could just add
> WARN_ON(fatal_signal_pending()) at the end of load_module() ?

We could and that's a good idea, thanks! This however would
at least allow the device to be functional in the case the
kill was received during kthread usage, but it would certainly
also set precedents for doing similar things in the kernel
which I do agree with is hacky. If we had upstream at
least WARN_ON(fatal_signal_pending()) as you note then
I think it would at least be a reasonable compromise.

> Not only kthread_create() can fail if systemd sends SIGKILL.

Sure, although its currently the only source found and debugged.

> > Although Oleg had rejected a
> > similar change a while ago
> 
> And honestly, I still dislike this change.

Don't blame you. The code is sensitive and hacky.

  Luis
