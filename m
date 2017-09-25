From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Mon, 25 Sep 2017 22:42:22 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1709252216410.2418@nanos>
References: <20170908170409.GA10020@u40b0340c692b58f6553c.ant.amazon.com> <20170908.101657.2131282706895004921.davem@davemloft.net> <1504891402.32080.5.camel@infradead.org> <20170908.102645.1086537961399780085.davem@davemloft.net>
 <20170908185521.GA12340@u40b0340c692b58f6553c.ant.amazon.com> <1504897909.15310.89.camel@edumazet-glaptop3.roam.corp.google.com> <alpine.DEB.2.20.1709161131200.2105@nanos> <20170920224816.GA73561@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Eduardo Valentin <eduval@amazon.com>,
        David Miller <davem@davemloft.net>, dwmw2@infradead.org,
        shuah@kernel.org, richardcochran@gmail.com,
        xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, anchalag@amazon.com, dwmw@amazon.com
To: Vallish Vaidyeshwara <vallish@amazon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920224816.GA73561@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Sep 2017, Vallish Vaidyeshwara wrote:
> On Sat, Sep 16, 2017 at 11:47:56AM +0200, Thomas Gleixner wrote:
> > > So if we need to replace all 'legacy' timers to high resolution timer,
> > > because some application was _relying_ on jiffies being kind of precise,
> > > maybe it is better to revert the change done on legacy timers.
> > 
> > Which would be a major step back in terms of timer performance and system
> > disturbance caused by massive recascading operations.
> > 
> > > Or continue the migration and make them use high res internally.
> > > 
> > > select() and poll() are the standard way to have precise timeouts,
> > > it is silly we have to maintain a timeout handling in the datagram fast
> > > path.
> > 
> > A few years ago we switched select/poll over to use hrtimers because the
> > wheel timers were too inaccurate for some operations, so it feels
> > consequent to switch the timeout in the datagram rcv path over as well. I
> > agree that the whole timeout magic there feels silly, but unfortunately
> > it's a documented property of sockets.
> > 
> 
> Thanks for your comments. This patch has been NACK'ed by David Miller. Is
> there any other approach to solve this problem with out application code
> being recompiled?

We have only three options here:

   1) Do a massive revert of the timer wheel changes and lose all the
      benefits of that rework.

   2) Make that timer list -> hrtimer change in the datagram code

   3) Ignore it

#1 Would be pretty ironic as networking would take the biggest penalty of
   the revert.

#2 Is IMO the proper solution as it cures a user space visible regression,
   though the patch itself could be made way simpler

#3 Shrug

Dave, Eric?

Thanks,

	tglx
