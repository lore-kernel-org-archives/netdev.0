From: Zach Brown <zach.brown@ni.com>
Subject: Re: Pure polling mode for netdevices
Date: Thu, 27 Oct 2016 13:29:10 -0500
Message-ID: <20161027182909.GA4892@zach-desktop>
References: <20161021180316.GA305@zach-desktop>
 <1477075306.7065.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-rt-users@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477075306.7065.86.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 21, 2016 at 11:41:46AM -0700, Eric Dumazet wrote:
> On Fri, 2016-10-21 at 13:03 -0500, Zach Brown wrote:
> > Is there a way to get NAPI to poll all the time?
> > Or just any way to get netdevices to use only polling and no interrupts?
> > 
> > We have some rt targets where the jitter can be improved by disabling
> > interrupts and using just polling. In these cases we're okay with the
> > performance downsides that come with polling.
> > 
> > In particular we already have an implementation for the cadence macb driver
> > that does only polling mode and have verified that it improves the
> > jitter.
> > 
> > We're hoping for a more general existing solution or at the very least a
> > solution that would be accepted upstream. Any thoughts?
> 
> This is not yet done, although you could use busy poll infrastructure to
> get this without a kernel change.
> 
> Open as many TCP flows are necessary to traverse all the queues you care
> about, then loop on recvmsg() to trigger NAPI polling.
> 
> 

I looked into the busy poll infrastructure and I don't think it meets our
needs. We're not interested in minimizing the latency of the ethernet device,
but rather diminishing if not eliminating the system jitter cause by ethernet
interrupts. Not to mention that some interfaces like macb don't provide a lot
of the config options to make busy polling really work well. For example,
interrupt coalescing configuration. 

I was thinking more along the lines of an extenstion to the NAPI interface that
drivers can opt into that allows them to enter NAPI polling mode and never
leave when configured to do so.  
