From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: route cache DoS testing and softirqs
Date: Wed, 31 Mar 2004 22:40:24 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331171023.GA4543@in.ibm.com>
References: <20040329222926.GF3808@dualathlon.random> <200403302005.AAA00466@yakov.inr.ac.ru> <20040330211450.GI3808@dualathlon.random> <20040330133000.098761e2.davem@redhat.com> <20040330213742.GL3808@dualathlon.random>
Reply-To: dipankar@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, paulmck@us.ibm.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrea Arcangeli <andrea@suse.de>
Content-Disposition: inline
In-Reply-To: <20040330213742.GL3808@dualathlon.random>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2004 at 11:37:42PM +0200, Andrea Arcangeli wrote:
> On Tue, Mar 30, 2004 at 01:30:00PM -0800, David S. Miller wrote:
> > On Tue, 30 Mar 2004 23:14:50 +0200
> > Andrea Arcangeli <andrea@suse.de> wrote:
> > 
> > > > There are no hardirqs in the case under investigation, remember?
> > > 
> > > no hardirqs? there must be tons of hardirqs if ksoftirqd never runs.
> > 
> > NAPI should be kicking in for this workload, and I know for a fact it is
> > for Robert's case.  There should only be a few thousand hard irqs per
> > second.
> > 
> > Until the RX ring is depleted the device's hardirqs will not be re-
> > enabled.
> 
> then Dipankar is reproducing with a workload that is completely
> different. I've only seen the emails from Dipankar so I couldn't know it
> was a NAPI load.
> 
> He posted these numbers:
> 
> 	softirq_count, ksoftirqd_count and other_softirq_count shows -
> 	
> 	CPU 0 : 638240  554     637686
> 	CPU 1 : 102316  1       102315
> 	CPU 2 : 675696  557     675139
> 	CPU 3 : 102305  0       102305
> 
> that means nothing runs in ksoftirqd for Dipankar, so he cannot be using
> NAPI.

And I am not. I am still on 2.6.0 and there seems to be no NAPI support
for the e100 there. Should I try 2.6.4 where e100 has NAPI support ?

Anyway, even without softirqs on the back of hardirqs, there are
other ways of softirq overload as seen in Robert's setup.

Thanks
Dipankar
