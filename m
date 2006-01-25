From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: e100 oops on resume
Date: Wed, 25 Jan 2006 14:28:10 -0800
Message-ID: <4807377b0601251428q4cd0faabve51087052714718@mail.gmail.com>
References: <20060124225919.GC12566@suse.de>
	 <20060124232142.GB6174@inferi.kami.home>
	 <20060125090240.GA12651@suse.de> <20060125121125.GH5465@suse.de>
	 <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com>
	 <20060125201450.GA15102@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stefan Seyfried <seife@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932177AbWAYW2O@vger.kernel.org>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060125201450.GA15102@suse.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/25/06, Olaf Kirch <okir@suse.de> wrote:
> On Wed, Jan 25, 2006 at 11:37:40AM -0800, Jesse Brandeburg wrote:
> > its an interesting patch, but it raises the question why does
> > e100_init_hw need to be called at all in resume?  I looked back
> > through our history and that init_hw call has always been there.  I
> > think its incorrect, but its taking me a while to set up a system with
> > the ability to resume.
>
> I'll ask the folks here to give it a try tomorrow. But I suspect at
> least some of it will be needed. For instance I assume you'll
> have to reload to ucode when bringing the NIC back from sleep.

I totally agree thats what it looks like, but unless I'm missing
something e100_up will take care of everything, and if the interface
is not up, e100_open->e100_up afterward will take care of it.

we have to be really careful about what might happen when resuming on
a system with a SMBUS link to a BMC, as there are some tricky
transitions in the hardware that can be easily violated.

Jesse
