From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: tg3 'No PHY devices' loading issue
Date: Tue, 17 Apr 2012 15:39:09 -0400
Message-ID: <20120417193908.GG19507@zod.bos.redhat.com>
References: <20120417141856.GA19507@zod.bos.redhat.com>
 <20120417185007.GA3742@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120417185007.GA3742@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 11:50:07AM -0700, Matt Carlson wrote:
> On Tue, Apr 17, 2012 at 10:18:57AM -0400, Josh Boyer wrote:
> > It has worked on some of the older kernels without the need for the
> > manual rmmod/modprobe step, so it seems to be somewhat timing related.
> > I'm not sure if there is a module load ordering issue, but that doesn't
> > seem to be the case.  I can't explain why a later modprobe would work
> > just fine though.
> > 
> > Do you have any thoughts on how to go about debugging/fixing this?  I'd
> > be happy to test and provide whatever information you need.
> 
> The 57788 uses the broadcom phylib module.  For some reason, it isn't
> available the first module load attempt.  A while ago, code was added to
> phylib to request modules from userspace if the particular phy support
> code wasn't already loaded.  It looks like this mechanism isn't working
> too well the first time through.
> 
> Can you reproduce the problem if you run 'rmmod broadcom' and then
> reload tg3?

I'll give it a shot, but that sounds like a quite plausible scenario to
me.  Oddly, even after the manual modprobe, the broadcom phy module
doesn't show an increased use count.  There's also no dependency on
'broadcom' listed for tg3 by modinfo.

josh
