From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Revert sky2 to 0.13a
Date: Mon, 27 Feb 2006 09:18:37 -0800
Message-ID: <20060227091837.3c214435@localhost.localdomain>
References: <4400FC28.1060705@gmx.net>
	<200602270003.46353.woho@woho.de>
	<20060227080042.0cf3f05d@localhost.localdomain>
	<200602271738.38675.woho@woho.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pomac@vapor.com,
	Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Pavel Volkovitskiy <int@mtx.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751511AbWB0RSu@vger.kernel.org>
To: woho@woho.de
In-Reply-To: <200602271738.38675.woho@woho.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Feb 2006 17:38:38 +0100
Wolfgang Hoffmann <woho@woho.de> wrote:

> On Monday 27 February 2006 17:00, Stephen Hemminger wrote:
> > On Mon, 27 Feb 2006 00:03:45 +0100
> >
> > Wolfgang Hoffmann <woho@woho.de> wrote:
> > > > Bisect done:
> > > >
> > > > 4d52b48b43d0d1d5959fa722ee0046e3542e5e1b is first bad commit
> > > >     [PATCH] sky2: support msi interrupt (revised)
> > > >
> > > > Reverting this commit in git head seems to work, at least the driver
> > > > builds and loads. Is that sane?
> > > >
> > > Ok, no hangs yet.
> > >
> > > Looking at the reverted commit, I wonder if modprobing sky2 with
> > > disable_msi=1 is equivalent to reverting the commit?
> >
> > Could you try the current code with the disable_msi option?
> > 	modprobe sky2 disable_msi=1
> >
> > That will run existing code without MSI.
> 
> 2.6.16-rc5 with disable_msi=1 works for me, no hangs seen so far. I rsynced 80 
> GB of data, thats about 5-10 times more than I typically need to reproduce a 
> hang, so it seems to be solid. For the record: 2.6.16-rc5 with disable_msi=0 
> does hang.
> 
> I have not seen the memory trashing others reported, with no version I tested 
> so far. Maybe my scenario is not likely to trigger this, so I can't tell.
> 
> Unless a fix for msi is at hand, may I suggest for 2.6.16 to revert the msi 
> commit or switch the default to disable_msi=1?
> 
> I've updated bugzilla #6084 accordingly.

Okay, then what I need is lspci -v of all systems that have the problem, I'll make
a blacklist (or update PCI quirks). I suspect that MSI doesn't work for any devices
on these systems, or MSI changes the timing enough to expose existing races. 
