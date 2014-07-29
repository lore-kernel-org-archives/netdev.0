From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred
 probefrom init
Date: Tue, 29 Jul 2014 15:25:29 -0700
Message-ID: <20140729222529.GC21140@f1.synalogic.ca>
References: <20140728234644.GA18729@kroah.com>
 <CAB=NE6UzK1ZEzm+54dwSyPwHGrAWCPtiNtxwhQuJF6tM9NbnYw@mail.gmail.com>
 <20140729003501.GA17020@kroah.com>
 <CAB=NE6XMzU+zJ0RMDKaPuSxfXBvN2vZ1DnbgxCjWHJquTD1iqg@mail.gmail.com>
 <53D744E3.10500@suse.de>
 <201407292107.EGB64066.OOQMFSHLJVtFFO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hare@suse.de, mcgrof@suse.com, gregkh@linuxfoundation.org,
	santosh@chelsio.com, hariprasad@chelsio.com, tiwai@suse.de,
	linux-kernel@vger.kernel.org, joseph.salisbury@canonical.com,
	kay@vrfy.org, gnomes@lxorguk.ukuu.org.uk,
	tim.gardner@canonical.com, pierre-fersing@pierref.org,
	akpm@linux-foundation.org, oleg@redhat.com,
	nagalakshmi.nandigama@avagotech.com,
	praveen.krishnamoorthy@avagotech.com,
	sreekanth.reddy@avagotech.com, abhijit.mahajan@avagotech.com,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54154 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203AbaG2WZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 18:25:43 -0400
Content-Disposition: inline
In-Reply-To: <201407292107.EGB64066.OOQMFSHLJVtFFO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/07/29 21:07, Tetsuo Handa wrote:
> Luis R. Rodriguez wrote:
> > On Mon, Jul 28, 2014 at 5:35 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > > On Mon, Jul 28, 2014 at 05:26:34PM -0700, Luis R. Rodriguez wrote:
> > >> To ignore SIGKILL ?
> > >
> > > Sorry, I thought this was a userspace change that caused this.
> > >
> > > As it's a kernel change, well, maybe that patch should be reverted...
> > 
> > That's certainly viable. Oleg?
> 
> I don't want to revert that patch.

I agree that 786235ee should not be reverted to fix the problem of
modules that receive sigkill from udev while they are initializing. In
fact, while it may fix the case that was reported with mptsas, it would
not fix cxgb4 because there are other code paths that check for pending
signals and that abort (ex. pci_vpd_pci22_wait()).

Reverting 786235ee effectively works around the problem by making
modprobe unkillable. The proper solution would be to make sure that udev
does not send sigkill to modprobe in the first place, either by making
the timeout longer or by making the module probe faster.

If you have other reasons for reverting 786235ee, then it's a different
story.
