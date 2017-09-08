From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Fri, 08 Sep 2017 12:11:49 -0700
Message-ID: <1504897909.15310.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170908170409.GA10020@u40b0340c692b58f6553c.ant.amazon.com>
         <20170908.101657.2131282706895004921.davem@davemloft.net>
         <1504891402.32080.5.camel@infradead.org>
         <20170908.102645.1086537961399780085.davem@davemloft.net>
         <20170908185521.GA12340@u40b0340c692b58f6553c.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dwmw2@infradead.org,
        vallish@amazon.com, shuah@kernel.org, richardcochran@gmail.com,
        xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, anchalag@amazon.com, dwmw@amazon.com
To: Eduardo Valentin <eduval@amazon.com>,
        Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908185521.GA12340@u40b0340c692b58f6553c.ant.amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-09-08 at 11:55 -0700, Eduardo Valentin wrote:
> Hello,
> 
> On Fri, Sep 08, 2017 at 10:26:45AM -0700, David Miller wrote:
> > From: David Woodhouse <dwmw2@infradead.org>
> > Date: Fri, 08 Sep 2017 18:23:22 +0100
> > 
> > > I don't know that anyone's ever tried saying "show me the chapter
> and
> > > verse of the documentation"
> > 
> > Do you know why I brought this up?  Because the person I am replying
> > to told me that the syscall documentation should have suggested this
> > or that.
> > 
> > That's why.
> 
> :-) My intention was for sure not to upset anybody.
> 
> Just to reiterate, the point of patch is simple, there was a change in
> behavior in the system call from one kernel version to the other. As I
> mentioned, I agree that the userspace could use other means to achieve
> the same, but still the system call behavior has changed.
> 
> > 
> > So let's concentrate on the other aspects of my reply, ok?
> 
> I agree. I would prefer to understand here what is the technical
> reason not to accept these patches other than "use other system
> calls".

So if we need to replace all 'legacy' timers to high resolution timer,
because some application was _relying_ on jiffies being kind of precise,
maybe it is better to revert the change done on legacy timers.

Or continue the migration and make them use high res internally.

select() and poll() are the standard way to have precise timeouts,
it is silly we have to maintain a timeout handling in the datagram fast
path.
