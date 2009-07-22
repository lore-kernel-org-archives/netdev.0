From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/1] veth: don't free priv->status until
	dev->destructor (v2)
Date: Wed, 22 Jul 2009 10:55:01 -0500
Message-ID: <20090722155501.GA12820@us.ibm.com>
References: <20090626162418.GA24828@us.ibm.com> <20090715.085012.223420354.davem@davemloft.net> <20090720142542.4fb12c12@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, containers@lists.osdl.org,
	sachinp@in.ibm.com, netdev@vger.kernel.org, matthltc@us.ibm.com,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753290AbZGVPzU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090720142542.4fb12c12@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Stephen Hemminger (shemminger@vyatta.com):
> On Wed, 15 Jul 2009 08:50:12 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: "Serge E. Hallyn" <serue@us.ibm.com>
> > Date: Fri, 26 Jun 2009 11:24:18 -0500
> > 
> > > I haven't been able to reproduce the original oops though (been
> > > trying to cat the stats sysfs files while rmmoding veth, to no
> > > avail, and haven't found an original bug report or testcase), so
> > > can't verify whether this patch prevents the original oops.
> > 
> > If you 'cat' it you're unlikely to trigger the oops.
> > 
> > You have to hold the sysfs files open, and then elsewhere do the
> > rmmod, wait, and then continue with some access to those open sysfs
> > file descriptors (f.e. do some reads).

Yup, I was doing that too, but couldn't reproduce as yet.

> > I'd also need this patch to be against current sources as they'll
> > never apply since I did the revert quite some time ago.
> > 
> > Thanks.

Ok, thanks - I'll generate a new patch against a fresh pull when
I can confirm that it actually solves the problem.

> My usual way of doing this is:
> 
> #  (sleep 30; cat /sys/class/net/ethX/statistics/tx_bytes) &
> # rmmod the_buggy_driver
> 
> wait...

Can you oops the kernel this way on latest netns?

thanks,
-serge
