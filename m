From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: e100 oops on resume
Date: Wed, 25 Jan 2006 16:28:48 -0800
Message-ID: <4807377b0601251628k4227dad0ld731f2c25c211b91@mail.gmail.com>
References: <20060124225919.GC12566@suse.de>
	 <20060124232142.GB6174@inferi.kami.home>
	 <20060125090240.GA12651@suse.de> <20060125121125.GH5465@suse.de>
	 <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stefan Seyfried <seife@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751269AbWAZA2x@vger.kernel.org>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/25/06, Jesse Brandeburg <jesse.brandeburg@gmail.com> wrote:
> On 1/25/06, Olaf Kirch <okir@suse.de> wrote:
> > On Wed, Jan 25, 2006 at 10:02:40AM +0100, Olaf Kirch wrote:
> > > I'm not sure what the right fix would be. e100_resume would probably
> > > have to call e100_alloc_cbs early on, while e100_up should avoid
> > > calling it a second time if nic->cbs_avail != 0. A tentative patch
> > > for testing is attached.
> >
> > Reportedly, the patch fixes the crash on resume.
>
> Cool, thanks for the research, I have a concern about this however.
>
> its an interesting patch, but it raises the question why does
> e100_init_hw need to be called at all in resume?  I looked back
> through our history and that init_hw call has always been there.  I
> think its incorrect, but its taking me a while to set up a system with
> the ability to resume.
>
> everywhere else in the driver alloc_cbs is called before init_hw so it
> just seems like a long standing bug.
>
> comments?  anyone want to test? i compile tested this, but it is untested.

Okay I reproduced the issue on 2.6.15.1 (with S1 sleep) and was able
to show that my patch that just removes e100_init_hw works okay for
me.  Let me know how it goes for you, I think this is a good fix.

Jesse
