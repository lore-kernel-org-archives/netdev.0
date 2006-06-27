From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 18:23:09 +0200
Message-ID: <200606271823.09998.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <200606271636.08473.mb@bu3sch.de> <44A15864.6000408@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:59535
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161163AbWF0QYZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 12:24:25 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44A15864.6000408@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 June 2006 18:10, Jeff Garzik wrote:
> Michael Buesch wrote:
> > On Tuesday 27 June 2006 16:11, Jeff Garzik wrote:
> >> Overall, bcm43xx is _really really bad_ about this sort of thing.  Just 
> >> grepping for udelay in bcm43xx_radio.c shows some of the worst 
> >> offenders.  bcm43xx_radio_init2060() and bcm43xx_radio_selectchannel() 
> >> both look like candidates for using msleep() rather than udelay().
> > 
> > This is _all_ at initialization time.
> > select_channel.... How often do you select a channel?
> 
> That question is irrelevant, because you have no idea what -else- is 
> going on in the system, at the point when bcm43xx chooses to spin the 
> CPU heavily.
> 
> Initialization time means you are definitely not in a hot path, and can 
> therefore sleep.

Ok, again:
If you are running a preemptible kernel (I am doing a patch for the
non-preemptible case), everything is _already_ fine.
We are not spinning long times with locks held or IRQs disabled.
I already fixed that.

And no, I don't really care for initialization time.
I am not going to potentially break the driver to remove
1ms of wasted CPU on ifconfig up.
In fact, initialization is and always was done lockless.
So we should be fine there, too, actually.

We don't know why these delays are there all. And we never will.
But as this are all some measuring an calibration routines,
they surely have some purpose. We don't know if longer delays
in some places may have ill effects. Making the whole thing
preemptible (as I am doing / have done) surely has its potential
to break the driver.

I prefer correct operation over an unnoticable 1ms CPU hog.

> > I recently reworked the periodically exectuted workhandlers,
> > so that they are preemptible.
> 
> Major classes of users run their kernels without preempt.  Please don't 
> depend on that to avoid bad behavior.

I am doing a patch atm.
I will add voluntary preemption points, if the kernel is not preemptible.

-- 
Greetings Michael.
